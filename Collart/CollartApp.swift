//
//  CollartApp.swift
//  Collart
//

import SwiftUI

@main
struct CollartApp: App {
    @StateObject var settingsManager = SettingsManager()
    @StateObject var userManager = UserManager.shared

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
        }
    }
}
