//
//  PasswordField.swift
//  Collart
//

import SwiftUI

struct PasswordField: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    let placeHolder: String
    @Binding var fieldText: String
    
    @Binding var isValid: Bool
    var validateMethod: (String) -> Bool = {_ in return true}
    var errorText: String = ""
    
    @State private var isEdited: Bool = false
    @FocusState private var focusedField: Bool
    
    var body: some View {
        VStack {
            SecureField("", text: $fieldText, prompt: Text(placeHolder).foregroundColor(settingsManager.currentTheme.textColorLightPrimary))
                .autocapitalization(.none)
                .focused($focusedField)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: focusedField || !fieldText.isEmpty), lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 100).fill(Color.clear))
                        .contentShape(RoundedRectangle(cornerRadius: 100))
                        .onTapGesture {
                            focusedField = true
                        }
                )
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
