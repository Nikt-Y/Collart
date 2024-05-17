//
//  DetailSpecialistViewModel.swift
//  Collart
//

import SwiftUI

final class DetailSpecialistViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var specProfile: User
    @Published var showInviteSelect = false
    @Published var selectedProjectsForInvite: [Order] = []
    @Published var isLoading = false
    @Published var loadingInvite = false
    
    private var profileService: ProfileServiceDelegate {
        networkService
    }
    private var interactionsService: InteractionsServiceDelegate {
        networkService
    }
    
    init(specProfile: Specialist) {
        self.specProfile = User(
            id: specProfile.id,
            backgroundImage: specProfile.backgroundImage,
            avatar: specProfile.specImage,
            name: "\(specProfile.name)",
            surname: "",
            profession: specProfile.profession,
            email: specProfile.email,
            subProfessions: [specProfile.subProfession],
            tools: [],
            searchable: false,
            experience: "no_experience"
        )
    }
    
    func loadData(for tab: DetailSpecTab) {
        isLoading = true
        switch tab {
        case .portfolio:
            profileService.fetchPortfolio(userId: specProfile.id) { result in
                switch result {
                case .success(let portfolioProjects):
                    self.specProfile.portfolioProjects = portfolioProjects.map { proj in
                        PortfolioProject(id: proj.id, projectImage: proj.image, projectName: proj.name, description: proj.description, ownerId: proj.user.id, files: proj.files)
                    }
                case .failure(let error):
                    print("Error fetching portfolio: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        case .collaborations:
            profileService.fetchCompletedCollaborations(userId: specProfile.id) { result in
                switch result {
                case .success(let projects):
                    self.interactionsService.fetchUserInteractions(userId: self.specProfile.id) { result in
                        switch result {
                        case .success(let interactions):
                            self.specProfile.oldProjects = []
                            for proj in projects {
                                var contributors: [Specialist] = []
                                for interaction in interactions {
                                    if interaction.order.order.id == proj.order.id {
                                        if !contributors.contains(where: { $0.id == interaction.getter.user.id }) {
                                            contributors.append(Specialist.transformToSpecialist(from: interaction.getter))
                                        }
                                        if !contributors.contains(where: { $0.id == interaction.sender.user.id }) {
                                            contributors.append(Specialist.transformToSpecialist(from: interaction.sender))
                                        }
                                    }
                                }
                                self.specProfile.oldProjects.append(OldProject(contributors: contributors, project: Order.transformToOrder(from: proj)))
                            }
                        case .failure(let failure):
                            break
                        }
                        self.isLoading = false
                    }
                case .failure(let error):
                    print("Error fetching portfolio: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        case .active:
            profileService.fetchUserOrders(userId: specProfile.id) { result in
                switch result {
                case .success(let projects):
                    self.specProfile.activeProjects = projects.map { Order.transformToOrder(from: $0) }
                case .failure(let error):
                    print("Error fetching portfolio: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }
    
    func sendInvites() {
        loadingInvite = true
        for selectedProject in selectedProjectsForInvite {
            interactionsService.sendInvite(orderID: selectedProject.id, getterID: specProfile.id) { success, error in
                self.loadingInvite = false
                self.showInviteSelect.toggle()
                self.selectedProjectsForInvite = []
            }
        }
    }
}
