//
//  SearchBarLight.swift
//  Collart
//

import SwiftUI

struct SearchBarLight: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Binding var text: String
    
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                TextField("", text: $text, prompt: Text("Поиск...").foregroundColor(settingsManager.currentTheme.textColorLightPrimary))
                    .focused($isTextFieldFocused)
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(settingsManager.currentTheme.searchColor)
                    .cornerRadius(8)
                    .onChange(of: isTextFieldFocused) { newValue in
                        if newValue {
                            withAnimation {
                                self.isEditing = true
                            }
                        } else {
                            withAnimation {
                                if self.text.isEmpty {
                                    self.isEditing = false
                                }
                            }
                        }
                    }
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            
                            if isEditing {
                                Button(action: {
                                    self.text = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
            }
            .background(settingsManager.currentTheme.searchColor)
            .cornerRadius(8)
            .contentShape(Rectangle()) // Extend tap area to the entire HStack
            .onTapGesture {
                if !isEditing {
                    withAnimation {
                        self.isEditing = true
                        self.isTextFieldFocused = true
                    }
                }
            }
            
            if isEditing {
                Button(action: {
                    withAnimation {
                        self.isEditing = false
                        self.text = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }) {
                    Text("Отмена")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: isEditing)
    }
}
