//
//  MainViewModel.swift
//  Collart
//

import SwiftUI

class MainViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var isUserFetched = false
    
    private var networkServiceDelegate: ProfileServiceDelegate & OrderServiceDelegate { networkService }
    
    func fetchUserData() {
        networkServiceDelegate.fetchAuthenticatedUser { result in
            switch result {
            case .success(let userDetails):
                UserManager.shared.user.id = userDetails.user.id
                self.fetchUserOrders(userId: userDetails.user.id)
            case .failure(let error):
                UserManager.shared.token = nil
                print("Error fetching authenticated user: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchUserOrders(userId: String) {
        networkServiceDelegate.fetchUserOrders(userId: userId) { result in
            switch result {
            case .success(let orders):
                UserManager.shared.user.activeProjects = orders.compactMap { order in
                    if order.order.isActive {
                        return Order.transformToOrder(from: order)
                    } else {
                        return nil
                    }
                }
                self.fetchFavorites(userId: userId)
            case .failure(let error):
                print("Error fetching orders: \(error.localizedDescription)")
                UserManager.shared.token = nil
            }
        }
    }
    
    private func fetchFavorites(userId: String) {
        networkServiceDelegate.fetchFavorites(userId: userId) { result in
            switch result {
            case .success(let orders):
                UserManager.shared.user.liked = orders.map { order in
                    Order.transformToOrder(from: order)
                }
                self.isUserFetched = true
            case .failure(let failure):
                print("Error fetching favorites: \(failure.localizedDescription)")
                self.isUserFetched = true
            }
        }
    }
}
