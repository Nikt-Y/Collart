//
//  OnboardingScreenView.swift
//  Collart
//

import SwiftUI

struct OnboardingScreenView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    let screen: OnboardingScreen

    var body: some View {
        VStack {
            Text(screen.title)
                .font(.system(size: screen.isLast ? settingsManager.textSizeSettings.appName : settingsManager.textSizeSettings.pageName))
                .fontWeight(.bold)
                .foregroundColor(settingsManager.currentTheme.primaryColor)
                .multilineTextAlignment(.center)
                .padding(.bottom, 33)
            Text(screen.description)
                .font(.system(size: settingsManager.textSizeSettings.subTitle))
                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
