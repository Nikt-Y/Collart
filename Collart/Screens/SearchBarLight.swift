//
//  SearchBar.swift
//  Collart
//
//  Created by Nik Y on 28.01.2024.
//

import SwiftUI

// TODO: Сделать так, чтобы пропадал фокус на 
struct SearchBarLight: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Binding var text: String
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("", text: $text, prompt:
                        Text("Поиск ...")
                .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
            )
            .foregroundColor(settingsManager.currentTheme.textColorPrimary)
            .padding(7)
            .padding(.horizontal, 25)
            .background(settingsManager.currentTheme.searchColor)
            .cornerRadius(8)
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
            .onTapGesture {
                withAnimation {
                    self.isEditing = true
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
                .transition(.move(edge: .trailing))
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarLight(text: .constant(""))
            .environmentObject(SettingsManager())
            .preferredColorScheme(.dark)
    }
}
