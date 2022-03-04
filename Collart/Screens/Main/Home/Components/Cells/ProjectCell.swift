//
//  ProjectCell.swift
//  Collart
//
//  Created by Nik Y on 17.02.2024.
//

import SwiftUI

struct ProjectCell: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var project: Project

    let projectImage = Image(systemName: "photo.artframe")
    let projectName = "ZULI POSADA"
    let roleRequired = "Графический дизайнер"
    let requirement = "отрисовка логотипа по ТЗ"
    let experience = "от 2 лет"
    let tools = "Adobe Illustrator, Figma"
    let authorAvatar = Image(systemName: "photo.artframe")
    let authorName = "Jane Kudrinskaia"
    
    var body: some View {
        VStack {
            projectImage
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipped()
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(projectName)
                    .font(.system(size: settingsManager.textSizeSettings.body))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .padding(.bottom, 1)
                
                Text(roleRequired)
                    .font(.system(size: settingsManager.textSizeSettings.title))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .bold()
                    .padding(.bottom, 11)
                
                Group {
                    Text("Что требуется: \(requirement)")
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                    
                    Text("Опыт работы: \(experience)")
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                    
                    Text("Программы: \(tools)")
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                        .padding(.bottom, 10)
                }
                .lineLimit(2)
                
                HStack {
                    authorAvatar
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .foregroundColor(.black)
                    
                    Text(authorName)
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                }
                .padding(.bottom, 10)
                
                Button("Откликнуться") {
                    print("Откликнуться")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.bottom, 2)
    }
}

//struct ProjectCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectCell()
//            .environmentObject(SettingsManager())
//    }
//}
