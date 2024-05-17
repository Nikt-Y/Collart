//
//  DetailProjectViewModel.swift
//  Collart
//

import SwiftUI

class DetailProjectViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var project: Order
    @Published var isFavorite: Bool = false
    
    private var orderService: OrderServiceDelegate {
        networkService
    }
    
    init(project: Order) {
        self.project = project
        checkIfFavorite()
    }
    
    func checkIfFavorite() {
        isFavorite = UserManager.shared.user.liked.contains { $0.id == project.id }
    }
    
    func toggleFavoriteStatus() {
        if isFavorite {
            orderService.removeOrderFromFavorites(orderId: project.id) { success, error in
                if success {
                    DispatchQueue.main.async {
                        UserManager.shared.user.liked.removeAll { $0.id == self.project.id }
                        self.isFavorite = false
                    }
                }
            }
        } else {
            orderService.addOrderToFavorites(orderId: project.id) { success, error in
                if success {
                    DispatchQueue.main.async {
                        UserManager.shared.user.liked.append(self.project)
                        self.isFavorite = true
                    }
                }
            }
        }
    }
    
    func deleteOrder(completion: @escaping () -> Void) {
        orderService.deleteOrder(orderId: project.id) { success, error in
            DispatchQueue.main.async {
                if success {
                    ToastManager.shared.show(message: "Проект успешно удален")
                    completion()
                }
            }
        }
    }
}
