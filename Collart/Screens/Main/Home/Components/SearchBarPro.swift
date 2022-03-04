//
//  SearchBarPro.swift
//  Collart
//
//  Created by Nik Y on 03.02.2024.
//

import SwiftUI

struct SearchBarPro: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    @Binding var text: String
    @Binding var showFilters: Bool
    
    @State private var isEditing = false
    
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
            
                TextField("", text: $text, prompt:
                            Text("Поиск")
                    .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                )
                .padding(.vertical, 12)
                .padding(.trailing, 40)
                .onTapGesture {
                    withAnimation {
                        self.isEditing = true
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
            }
            .background(settingsManager.currentTheme.searchColor)
            .clipShape(Capsule())
            
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

struct SearchBarPro_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarPro(text: .constant(""), showFilters: .constant(true))
            .environmentObject(SettingsManager())
            .preferredColorScheme(.dark)
    }
}
