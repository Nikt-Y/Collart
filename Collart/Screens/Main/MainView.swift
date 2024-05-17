//
//  MainView.swift
//  Collart
//
//  Created by Nik Y on 17.03.2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var viewModel = MainViewModel()
    @State var isUserFetched = false
    
    var body: some View {
        NavigationStack {
            if !isUserFetched {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                    .scaleEffect(3)
                    .onAppear {
                        NetworkService.fetchAuthenticatedUser { result in
                            switch result {
                            case .success(let userDetails):
                                UserManager.shared.user.id = userDetails.user.id
                                NetworkService.fetchUserOrders(userId: userDetails.user.id) { result in
                                    switch result {
                                    case .success(let orders):
                                        UserManager.shared.user.activeProjects = orders.compactMap({ order in
                                            if order.order.isActive {
                                                return Order.transformToOrder(from: order)
                                            } else {
                                                return nil
                                            }
                                        })
                                        NetworkService.fetchFavorites(userId: userDetails.user.id) { result in
                                            switch result {
                                            case .success(let orders):
                                                UserManager.shared.user.liked = orders.map({ order in
                                                    Order.transformToOrder(from: order)
                                                })
                                            case .failure(let failure):
                                                break
                                            }
                                            isUserFetched = true
                                        }
                                        
                                    case .failure(let error):
                                        print("Error fetching orders: \(error.localizedDescription)")
                                        UserManager.shared.token = nil
                                    }
                                }
                                print("Authenticated User: \(userDetails)")
                            case .failure(let error):
                                // Обработка ошибки
                                UserManager.shared.token = nil
                                print("Error fetching authenticated user: \(error.localizedDescription)")
                            }
                        }
                    }
            } else {
                TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                        }
                    //                .badge(1)
                    
                    InteractionsView()
                        .tabItem {
                            Image(systemName: "arrow.up.arrow.down.circle")
                        }
                    
                    ChatsListView()
                        .tabItem {
                            Image(systemName: "message")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.fill")
                        }
                }
                .tint(settings.currentTheme.primaryColor)
                .onAppear {
                    // Установка непрозрачного фона для UITabBar
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor(settings.currentTheme.backgroundColor)
                    UITabBar.appearance().standardAppearance = appearance
                    if #available(iOS 15.0, *) {
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                    }
                }
                .opacity(1)
            }
        }
        .background(settings.currentTheme.backgroundColor)
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
