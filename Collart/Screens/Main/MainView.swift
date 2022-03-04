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
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                }
//                .badge(1)
            ChatView()
                .tabItem {
                    Image(systemName: "message")
                }
            InteractionsView()
                .tabItem {
                    Image(systemName: "arrow.up.arrow.down.circle")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
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
