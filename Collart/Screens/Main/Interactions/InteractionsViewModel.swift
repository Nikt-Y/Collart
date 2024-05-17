//
//  InteractionsViewModel.swift
//  Collart
//

import SwiftUI

class InteractionsViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var responses: [Response] = []
    @Published var invites: [Invite] = []
    
    private var interactionsService: InteractionsServiceDelegate {
            networkService
        }
    
    func fetchInteractions(completion: @escaping () -> ()) {
        interactionsService.fetchUserInteractions(userId: UserManager.shared.user.id) { result in
            switch result {
            case .success(let interactions):
                self.responses = []
                self.invites = []
                for interaction in interactions {
                    if interaction.getter.user.id == UserManager.shared.user.id {
                        if UserManager.shared.user.id == interaction.order.order.owner.id {
                            let responser = UserManager.transformToUser(from: interaction.sender)
                            let proj = Order.transformToOrder(from: interaction.order)
                            let status = InteractionStatus(rawValue: interaction.status) ?? .active
                            self.responses.append(Response(id: interaction.id, responser: responser, project: proj, status: status))
                        } else {
                            let status = InteractionStatus(rawValue: interaction.status) ?? .active
                            var project = Order.transformToOrder(from: interaction.order)
                            project.authorAvatar = interaction.sender.user.userPhoto ?? ""
                            self.invites.append(Invite(id: interaction.id, project: project, status: status))
                        }
                    }
                }
            case .failure(let failure):
                break
            }
            completion()
        }
    }
}
