//
//  OnboardingNavigationButtonsView.swift
//  Collart
//

import SwiftUI

struct OnboardingNavigationButtonsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<viewModel.screens.count-1, id: \.self) { index in
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundColor(index == viewModel.currentIndex ? settingsManager.currentTheme.primaryColor : settingsManager.currentTheme.lightPrimaryColor)
                        .opacity(viewModel.isLast ? 0 : 1)
                }
            }
            .padding()
            
            
            if !viewModel.isLast {
                Button("Далее", action: viewModel.advancePage)
                    .buttonStyle(PrimaryButtonStyle())
                
                Button("Пропустить", action: viewModel.skipToEnd)
                    .buttonStyle(SecondaryButtonStyle())
            } else {
                NavigationLink(destination: LoginView()) {
                    Text("Вход")
                }
                .buttonStyle(PrimaryButtonStyle())
                
                NavigationLink(destination: RegistrationView()) {
                    Text("Регистрация")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            
        }
    }
}
