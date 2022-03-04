//
//  TextErrorField.swift
//  Collart
//
//  Created by Nik Y on 28.01.2024.
//

import SwiftUI

struct TextErrorField: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    let placeHolder: String
    @Binding var fieldText: String
    
    @Binding var isValid: Bool
    var validateMethod: (String) -> Bool = { _ in return true}
    var errorText: String = ""
    
    @State private var isEdited: Bool = false
    @FocusState private var focusedField: Int?

    var body: some View {
        VStack {
            TextField("", text: $fieldText, prompt: Text(placeHolder).foregroundColor(settingsManager.currentTheme.textColorLightPrimary))
                .focused($focusedField, equals: 0)
                .padding()
                .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: focusedField == 0 || !fieldText.isEmpty), lineWidth: 1))
                .font(.system(size: settingsManager.textSizeSettings.body))
                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                .onChange(of: fieldText) { newValue in
                    withAnimation {
                        isValid = validateMethod(newValue)
                        isEdited = true
                    }
                }
            
            if !errorText.isEmpty && !isValid && isEdited {
                HStack {
                    Text(errorText)
                        .foregroundColor(.red)
                        .padding(.leading)
                    Spacer()
                }
            }
        }
    }
}
