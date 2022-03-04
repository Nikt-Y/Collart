//
//  DetailProjectView.swift
//  Collart
//
//  Created by Nik Y on 13.03.2024.
//

import SwiftUI

struct DetailProjectView: View {
    @StateObject private var viewModel = DetailProjectViewModel()
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    let project: Project
    
    init(project: Project) {
        self.project = project
        viewModel.project = project
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(project.roleRequired)
                        .font(.system(size: settings.textSizeSettings.pageName))
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                        .bold()
                        .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "photo.artframe")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                        
                        Text(project.authorName)
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.black)
                        .padding(.bottom)
                    
                    
                    Group {
                        Text(project.projectName)
                            .font(.system(size: settings.textSizeSettings.subTitle))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                            .bold()
                        
                        Text("Что требуется: \(project.requirement)")
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Text("Опыт работы: \(project.experience)")
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Text("Программы: \(project.tools)")
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Text("О проекте:")
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Text(project.description)
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                    }
                    .padding(.horizontal)
                }
            }
            
            Button(action: {}) {
                Text("Откликнуться")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Capsule().fill(Color.purple))
            }
            .padding()
        }
        .background(settings.currentTheme.backgroundColor)
    }
}

struct DetailProjectView_Previews: PreviewProvider {
    static var previews: some View {
        DetailProjectView(project: Project(projectImage: URL(string: "https://example.com/projectImage1.png")!, projectName: "ZULI POSADA", roleRequired: "Графический дизайнер", requirement: "отрисовка логотипа по ТЗ", experience: "от 2 лет", tools: "Adobe Illustrator, Figma", authorAvatar: URL(string: "https://example.com/authorAvatar1.png")!, authorName: "Jane Kudrinskaia", description: "lorem snk snd lkm sdf fnghfdh jngfdh jdfng kdjfng kjndf kgdkfjn kjngdf kjngdf kjngfd kjndfg kjndgf kjndfg kjngdf kjdnf f!"))
            .environmentObject(SettingsManager())
    }
}
