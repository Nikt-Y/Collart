//
//  InteractionsViewModel.swift
//  Collart
//
//  Created by Nik Y on 11.05.2024.
//

import Foundation

class InteractionsViewModel: ObservableObject {
    @Published var responses: [Response] = []
    @Published var invites: [Invite] = []
    
    func fetchInteractions(completion: @escaping () -> ()) {
        NetworkService.Interactions.fetchUserInteractions(userId: UserManager.shared.user.id) { result in
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

struct Response {
    var id: String
    var responser: User
    var project: Order
    var status: InteractionStatus
}

struct Invite {
    var id: String
    var project: Order
    var status: InteractionStatus
}
