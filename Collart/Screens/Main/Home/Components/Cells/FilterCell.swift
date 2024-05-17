//
//  FilterCell.swift
//  Collart
//

import SwiftUI

struct FilterCell: View {
    @EnvironmentObject var settings: SettingsManager
    var isSelected: Bool
    var text: String
    
    var body: some View {
        let textColor = isSelected ? settings.currentTheme.primaryColor : settings.currentTheme.textColorLightPrimary
        let strokeColor = isSelected ? Color.clear : settings.currentTheme.textColorLightPrimary
        let backgroundColor = isSelected ? settings.currentTheme.lightPrimaryColor : settings.currentTheme.backgroundColor

        Text(text)
            .lineLimit(1)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .font(.system(size: settings.textSizeSettings.body))
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(strokeColor, lineWidth: 2)
            )
            .cornerRadius(10)
            .foregroundColor(textColor)
    }
}
