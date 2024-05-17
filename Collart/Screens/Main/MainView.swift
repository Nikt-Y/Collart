//
//  MainView.swift
//  Collart
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack {
                if !viewModel.isUserFetched {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                        .scaleEffect(3)
                        .onAppear {
                            viewModel.fetchUserData()
                        }
                } else {
                    TabView {
                        HomeView()
                            .tabItem {
                                Image(systemName: "house.fill")
                            }
                        
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
            
            ToastView()
        }
    }
}
