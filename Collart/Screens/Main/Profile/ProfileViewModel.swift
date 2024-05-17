//
//  ProfileViewModel.swift
//  Collart
//

import SwiftUI

class ProfileViewModel: ObservableObject {
    static let shared = ProfileViewModel()
    
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var specProfile: User
    @Published var shouldReloadOrders = false
    @Published var shouldReloadPortfolio = false
    @Published var isLoading = false
    
    private var profileService: ProfileServiceDelegate & InteractionsServiceDelegate & OrderServiceDelegate {
        networkService
    }
    
    init () {
        self.specProfile = UserManager.shared.user
    }
    
    func fetchUser(completion: @escaping (Bool) -> Void) {
        let language = LocalPersistence.shared.language
        profileService.fetchAuthenticatedUser(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    UserManager.shared.user = User(
                        id: data.user.id,
                        backgroundImage: data.user.cover ?? "",
                        avatar: data.user.userPhoto ?? "",
                        name: "\(data.user.name!)",
                        surname: data.user.surname ?? "",
                        profession: data.skills.compactMap {
                            if $0.primary ?? false {
                                return language == "ru" ? $0.nameRu : $0.nameEn
                            } else {
                                return nil
                            }
                        }.joined(separator: ", "),
                        email: data.user.email ?? "",
                        subProfessions: data.skills.compactMap {
                            if !($0.primary ?? false) {
                                return language == "ru" ? $0.nameRu : $0.nameEn
                            } else {
                                return nil
                            }
                        },
                        tools: data.tools,
                        searchable: data.user.searchable ?? false,
                        experience: data.user.experience ?? "no_experience",
                        activeProjects: UserManager.shared.user.activeProjects,
                        liked: UserManager.shared.user.liked
                    )
                    self.specProfile = UserManager.shared.user
                    completion(true)
                case .failure(_):
                    completion(false)
                }
            }
        })
    }

    func loadData(for tab: ProfileTab) {
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
                    self.profileService.fetchUserInteractions(userId: self.specProfile.id) { result in
                        switch result {
                        case .success(let interactions):
                            self.specProfile.oldProjects = []
                            for proj in projects {
                                var contributors: [Specialist] = []
                                for interaction in interactions {
                                    if interaction.order.order.id == proj.order.id {
                                        if !contributors.contains(where: { spec in spec.id == interaction.getter.user.id }) {
                                            contributors.append(Specialist.transformToSpecialist(from: interaction.getter))
                                        }
                                        if !contributors.contains(where: { spec in spec.id == interaction.sender.user.id }) {
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
                    let projs = projects.map { proj in Order.transformToOrder(from: proj) }
                    self.specProfile.activeProjects = projs
                    UserManager.shared.user.activeProjects = projs
                case .failure(let error):
                    print("Error fetching portfolio: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        case .liked:
            profileService.fetchFavorites(userId: specProfile.id) { result in
                switch result {
                case .success(let projects):
                    let projs = projects.map { proj in Order.transformToOrder(from: proj) }
                    self.specProfile.liked = projs
                    UserManager.shared.user.liked = projs
                case .failure(let error):
                    print("Error fetching portfolio: \(error.localizedDescription)")
                }
                self.isLoading = false
            }
        }
    }
}
