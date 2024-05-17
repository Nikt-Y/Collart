//
//  CollartApp.swift
//  Collart
//
//  Created by Nik Y on 23.12.2023.
//

import SwiftUI

@main
struct CollartApp: App {
    @StateObject var settingsManager = SettingsManager()
    @StateObject var userManager = UserManager.shared

    // TODO: Упороться в NavigationStack и сделать нормально
    var body: some Scene {
        WindowGroup {
            if userManager.token != nil {
                MainView()
                    .environmentObject(settingsManager)
            } else {
                OnboardingView()
                    .environmentObject(settingsManager)
                    .preferredColorScheme(.dark)
            }
//            VStack {
//                SearchBarPro(text: $text, showFilters: $t)
//                    .environmentObject(settingsManager)
//                Spacer()
//            }
            
        }
    }
}

// TODO: Сделать так, чтобы можно было при нажатии кнопки на клаве перескакивать на некст ввод

