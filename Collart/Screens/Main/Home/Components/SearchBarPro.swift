//
//  SearchBarPro.swift
//  Collart
//

import SwiftUI

struct SearchBarPro: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Binding var text: String
    @Binding var showFilters: Bool
    
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            HStack {
                Button {
                    showFilters.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                        .padding(.leading, 10)
                }
                .zIndex(1)
                
                TextField("", text: $text, prompt: Text("Поиск").foregroundColor(settingsManager.currentTheme.textColorLightPrimary))
                    .focused($isTextFieldFocused)
                    .padding(.vertical, 12)
                    .padding(.trailing, 40)
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
                    .overlay {
                        HStack {
                            Spacer()
                            if isEditing {
                                Button(action: {
                                    self.text = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                                        .padding(.trailing, 14)
                                }
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                                    .padding(.trailing, 14)
                            }
                        }
                    }
                    .background(settingsManager.currentTheme.searchColor)
                    .clipShape(Rectangle())
            }
            .background(settingsManager.currentTheme.searchColor)
            .clipShape(Capsule())
            .contentShape(Rectangle())
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
    }
}
