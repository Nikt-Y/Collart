//
//  OnboardingView.swift
//  Collart
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @ObservedObject var viewModel = OnboardingViewModel()
    @State private var selectedPage = 0
    
    let transitionAnimation = Animation.easeInOut(duration: 1)
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                if viewModel.showLastScreen {
                    OnboardingScreenView(screen: viewModel.screens.last!)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .animation(transitionAnimation, value: viewModel.showLastScreen)
                }
                
                if !viewModel.isLast {
                    TabView(selection: $selectedPage) {
                        ForEach(0..<viewModel.screens.count - 1, id: \.self) { index in
                            OnboardingScreenView(screen: viewModel.screens[index])
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onReceive(viewModel.$currentIndex) { newIndex in
                        withAnimation(.easeInOut(duration: 0.7)) {
                            selectedPage = newIndex
                        }
                    }
                    .disabled(true)
                }
                
                Spacer()
                
                OnboardingNavigationButtonsView(
                    viewModel: viewModel
                )
            }
            .padding(20)
            .background(settingsManager.currentTheme.backgroundColor)
            .onChange(of: viewModel.isLast) { isLast in
                if isLast {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(transitionAnimation) {
                            viewModel.showLastScreen = true
                        }
                    }
                }
            }
        }
    }
    
}
