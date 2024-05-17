//
//  Styles.swift
//  Collart
//

import SwiftUI

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject var settings: SettingsManager
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(settings.currentTheme.primaryColor)
            .foregroundColor(settings.currentTheme.textColorOnPrimary)
            .font(.system(size: settings.textSizeSettings.subTitle))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct ConditionalButtonStyle: ButtonStyle {
    @EnvironmentObject var settings: SettingsManager
    var conditional: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(conditional ? settings.currentTheme.primaryColor : settings.currentTheme.textColorLightPrimary)
            .foregroundColor(settings.currentTheme.textColorOnPrimary)
            .font(.system(size: settings.textSizeSettings.subTitle))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @EnvironmentObject var settings: SettingsManager
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .frame(minWidth: 0, maxWidth: .infinity)
            .font(.system(size: settings.textSizeSettings.subTitle))
            .background(settings.currentTheme.backgroundColor)
            .overlay(
                Capsule()
                    .stroke(settings.currentTheme.primaryColor, lineWidth: 2)
            )
            .foregroundColor(settings.currentTheme.primaryColor)
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

struct IconButtonStyle: ButtonStyle {
    @EnvironmentObject var settings: SettingsManager
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(settings.currentTheme.primaryColor)
            .cornerRadius(8)
            .frame(width: 55, height: 55)
            .foregroundColor(settings.currentTheme.textColorOnPrimary)
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Text Styles
struct CustomTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .lineSpacing(10)
            .padding()
            .background(Color.yellow)
            .cornerRadius(10)
            .shadow(color: .gray, radius: 2, x: 0, y: 2)
    }
}

extension View {
    func customTextStyle() -> some View {
        self.modifier(CustomTextStyle())
    }
}

