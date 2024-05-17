//
//  CustomPicker.swift
//  Collart
//

import SwiftUI

// MARK: - Pickable protocol
protocol Pickable {
    var displayValue: String { get }
    static var allCases: [Self] { get }
}

// MARK: - CustomPicker
struct CustomPicker<T: Pickable & Hashable>: View where T: CaseIterable {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var selectedTab: T
    var expandsBeyondScreen: Bool = false
    
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
