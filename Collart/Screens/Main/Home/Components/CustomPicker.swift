//
//  CustomPicker.swift
//  Collart
//
//  Created by Nik Y on 04.02.2024.
//

import SwiftUI

protocol Pickable {
    var displayValue: String { get }
    static var allCases: [Self] { get }
}

struct CustomPicker<T: Pickable & Hashable>: View where T: CaseIterable {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var selectedTab: T
    var expandsBeyondScreen: Bool = false // Новый флаг
    
    var body: some View {
        Group {
            if expandsBeyondScreen {
                ScrollView(.horizontal, showsIndicators: false) {
                    pickerContent
                }
            } else {
                pickerContent
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
    
    // Вынесенное содержимое пикера для удобства
    private var pickerContent: some View {
        HStack(spacing: 0) {
            ForEach(T.allCases, id: \.self) { tab in
                VStack(spacing: 0) {
                    Text(tab.displayValue)
                        .font(.system(size: settingsManager.textSizeSettings.subTitle))
                        .foregroundColor(selectedTab == tab ? settingsManager.currentTheme.primaryColor : settingsManager.currentTheme.textColorLightPrimary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, expandsBeyondScreen ? 11 : 0)
                    Rectangle()
                        .frame(width: .infinity, height: 2)
                        .foregroundColor(selectedTab == tab ? settingsManager.currentTheme.primaryColor : settingsManager.currentTheme.backgroundColor)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTab = tab
                }
            }
        }
        .background(settingsManager.currentTheme.backgroundColor)
    }
}
