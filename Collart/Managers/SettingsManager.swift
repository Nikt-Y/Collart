//
//  SettingsManager.swift
//  Collart
//
//  Created by Nik Y on 28.12.2023.
//

import SwiftUI

protocol Theme {
    var primaryColor: Color { get }
    var lightPrimaryColor: Color { get }
    var backgroundColor: Color { get }
    
    var textColorPrimary: Color { get }
    var textColorLightPrimary: Color { get }
    var textColorOnPrimary: Color { get }
    var textDescriptionColor: Color { get }
    
    var searchColor: Color { get }
    
    func selectedButtonColor(isSelected: Bool) -> Color
    
    func selectedTextColor(isSelected: Bool) -> Color 
}

protocol TextSizable {
    var appName: CGFloat { get }
    var title: CGFloat { get }
    var subTitle: CGFloat { get }
    var body: CGFloat { get }
    var pageName: CGFloat { get }
    var semiPageName: CGFloat { get }
    var little: CGFloat { get }
    // Можете добавить другие свойства для разных стилей текста
    
    func adjustFontSize(for sizeCategory: ContentSizeCategory) -> Self
    // Добавьте другие методы, если необходимо
}

struct LightTheme: Theme {
    var primaryColor = Color(hex: "7700DD")
    var lightPrimaryColor = Color(hex: "E4CCF8")
    var backgroundColor = Color.white
    var searchColor: Color = Color(hex: "f2f2f7") // 1b1c1e для темной темы
    
    var textColorPrimary = Color.black
    var textColorLightPrimary = Color.gray
    var textColorOnPrimary = Color.white
    var textDescriptionColor: Color = Color(hex: "49454F")
    
    func selectedButtonColor(isSelected: Bool) -> Color {
        return isSelected ? primaryColor : textColorPrimary
    }
    
    func selectedTextColor(isSelected: Bool) -> Color {
        return isSelected ? textColorPrimary : textColorLightPrimary
    }
}

struct DefaultTextSizes: TextSizable {
    var appName: CGFloat = 36
    var pageName: CGFloat = 22
    var semiPageName: CGFloat = 20
    var title: CGFloat = 18
    var subTitle: CGFloat = 16
    var body: CGFloat = 16
    var little: CGFloat = 14
    
    func adjustFontSize(for sizeCategory: ContentSizeCategory) -> Self {
        var adjustedSizes = self
        switch sizeCategory {
        case .extraSmall:
            adjustedSizes.subTitle -= 2
        case .extraLarge:
            adjustedSizes.subTitle += 2
            // Определите настройки для других категорий
        default:
            break
        }
        return adjustedSizes
    }
}

enum Language: String {
    case ru = "ru"
    case en = "en"
}

class SettingsManager: ObservableObject {
    @Published var currentTheme: Theme = LightTheme()
    @Published var textSizeSettings: TextSizable = DefaultTextSizes()
    
    func switchToLightTheme() {
        currentTheme = LightTheme()
    }
    
    func adjustTextSize(for sizeCategory: ContentSizeCategory) {
        textSizeSettings = textSizeSettings.adjustFontSize(for: sizeCategory)
    }
}
