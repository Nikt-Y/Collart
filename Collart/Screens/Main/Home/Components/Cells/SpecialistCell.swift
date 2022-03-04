//
//  SpecialistCell.swift
//  Collart
//
//  Created by Nik Y on 17.02.2024.
//

import SwiftUI

// TODO: Может стоит добавить описание к специалисту?
struct SpecialistCell: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var specialist: Specialist
    
    let backgroundImage = Image(systemName: "photo.artframe")
    let specImage = Image(systemName: "photo.artframe")
    let name = "Luis Moreno"
    let profession = "Цифровой художник"
    let experience = "2 года"
    let tools = "Adobe Illustrator, Adobe Photoshop, Corel Painter, Procreate"
    
    var body: some View {
        VStack {
            backgroundImage
                .resizable()
                .scaledToFill()
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(.black)
                .padding()
                .overlay(alignment: .bottom) {
                    specImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .foregroundColor(.black)
                        .padding(5)
                        .background(settingsManager.currentTheme.backgroundColor)
                        .clipShape(Circle())
                        .offset(y: 10)
                }
            
            VStack(spacing: 5) {
                Text(name)
                    .font(.system(size: settingsManager.textSizeSettings.pageName))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .bold()
                    .padding(.bottom, 1)
                
                Text(profession)
                    .font(.system(size: settingsManager.textSizeSettings.title))
                    .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                    .padding(.bottom, 11)
                
                VStack(alignment: .leading) {
                    Group {
                        Text("Опыт работы: \(experience)")
                            .font(.system(size: settingsManager.textSizeSettings.body))
                            .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                        
                        Text("Программы: \(tools)")
                            .font(.system(size: settingsManager.textSizeSettings.body))
                            .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                    }
                    .lineLimit(2)
                }
                
                Button("Пригласить") {
                    // action
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding()
            }
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.bottom, 2)
    }
}
//
//struct SpecialistCell_Previews: PreviewProvider {
//    static var previews: some View {
//        SpecialistCell()
//            .environmentObject(SettingsManager())
//    }
//}
