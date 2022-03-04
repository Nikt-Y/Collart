//
//  CustomPicker.swift
//  Collart
//
//  Created by Nik Y on 04.02.2024.
//

import SwiftUI

struct CustomPicker: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Text("Проекты")
                    .font(.system(size: settingsManager.textSizeSettings.subTitle))
                    .foregroundColor(selectedTab == .projects ? settingsManager.currentTheme.primaryColor : settingsManager.currentTheme.textColorLightPrimary)
                    .padding(.vertical, 10)
                Rectangle()
                    .frame(width: .infinity, height: 2)
                    .foregroundColor(selectedTab == .projects ? settingsManager.currentTheme.primaryColor : settingsManager.currentTheme.backgroundColor)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedTab = .projects
            }
            
            VStack(spacing: 0) {
                Text("Специалисты")
                    .font(.system(size: settingsManager.textSizeSettings.subTitle))
                    .foregroundColor(selectedTab == .specialists ? settingsManager.currentTheme.primaryColor : settingsManager.currentTheme.textColorLightPrimary)
                    .padding(.vertical, 10)
                Rectangle()
                    .frame(width: .infinity, height: 2)
                    .foregroundColor(selectedTab == .specialists ? settingsManager.currentTheme.primaryColor : settingsManager.currentTheme.backgroundColor)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedTab = .specialists
            }
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

