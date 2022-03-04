//
//  OnboardingViewModel.swift
//  Collart
//
//  Created by Nik Y on 28.12.2023.
//

import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentIndex = 0
    @Published var isLast = false
    @Published var showLastScreen = false
    
    var screens = [
        OnboardingScreen(title: "Добро пожаловать в Collart!", description: "", isLast: false),
        OnboardingScreen(title: "Находите специалистов для коллаборации", description: "Благодаря возможностям поиска и приглашения специалистов в свой проекты", isLast: false),
        OnboardingScreen(title: "Создавайте личное портфолио", description: "Загружайте свои проекты, чтобы другие пользователи приглашали Вас в коллаборации", isLast: false),
        OnboardingScreen(title: "Collart", description: "", isLast: true)
    ]
    
    func advancePage() {
        if currentIndex < screens.count - 2 {
            withAnimation {
                currentIndex += 1
            }
        } else {
            withAnimation {
                isLast = true
            }
        }
    }
    
    func skipToEnd() {
        withAnimation {
            isLast = true
        }
    }
}
