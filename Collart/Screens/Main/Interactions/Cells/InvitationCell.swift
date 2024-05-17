//
//  InvitationCell.swift
//  Collart
//
//  Created by Nik Y on 28.03.2024.
//

import SwiftUI
import CachedAsyncImage

enum InteractionStatus: String {
    case active = "active"
    case accepted = "accepted"
    case rejected = "rejected"
}

struct InvitationCell: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State var isAvailable: Bool = true
    
    var id: String
    var project: Order
    @State var status: InteractionStatus
    @State var rejectLoading = false
    @State var acceptLoading = false
    
    var onRespond: () -> Void = {}
//    let projectImage = Image(systemName: "photo.artframe")
//    let projectName = "ZULI POSADA"
//    let roleRequired = "Графический дизайнер"
//    let requirement = "отрисовка логотипа по ТЗ"
//    let experience = "от 2 лет"
//    let tools = "Adobe Illustrator, Figma"
//    let authorAvatar = Image(systemName: "photo.artframe")
//    let authorName = "Jane Kudrinskaia"
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: !project.projectImage.isEmpty ? project.projectImage : "no url"), urlCache: .imageCache) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                case .failure(_):
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                @unknown default:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                }
            }
                .frame(height: 150)
                .clipped()
                .clipShape(Rectangle())
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(project.projectName)
                    .font(.system(size: settingsManager.textSizeSettings.body))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .padding(.bottom, 1)
                
                Text(project.roleRequired)
                    .font(.system(size: settingsManager.textSizeSettings.title))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .bold()
                    .padding(.bottom, 11)
                
                Group {
                    Text("Что требуется: \(project.requirement)")
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                    
                    Text("Опыт работы: \(project.experience)")
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                    
                    Text("Программы: \(project.tools)")
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                        .padding(.bottom, 10)
                }
                .lineLimit(2)
                
                HStack {
                    CachedAsyncImage(url: URL(string: !project.authorAvatar.isEmpty ? project.authorAvatar : "no url"), urlCache: .imageCache) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                        case .failure(_):
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                        @unknown default:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                        }
                    }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        .foregroundColor(.black)
                    
                    Text(project.authorName)
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                }
                
                HStack {
                    switch status {
                    case .active:
                        Button {
                            rejectLoading = true
                            NetworkService.Interactions.rejectInteraction(interactionId: id, getterID: UserManager.shared.user.id) { success, error in
                                if success {
                                    status = .rejected
                                }
                                rejectLoading = false
                            }
                            
                        } label: {
                            if rejectLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                            } else {
                                Text("Отклонить")
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding(10)
                        
                        Button {
                            acceptLoading = true
                            NetworkService.Interactions.acceptInteraction(interactionId: id, getterID: UserManager.shared.user.id) { success, error in
                                if success {
                                    status = .accepted
                                }
                                acceptLoading = false
                            }
                            
                        } label: {
                            if acceptLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                            } else {
                                Text("Принять")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(10)
                    case .accepted:
                        Button("Приглашение принято!") {
//                            status = .active
                        }
                        .bold()
                        .padding(.vertical, 12)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(hex: "00BF32"))
                        .foregroundColor(settingsManager.currentTheme.textColorOnPrimary)
                        .font(.system(size: settingsManager.textSizeSettings.subTitle))
                        .clipShape(Capsule())
                        .padding(10)
                        
                    case .rejected:
                        Button("Приглашение отклонено!") {
//                            status = .active
                        }
                        .bold()
                        .padding(.vertical, 12)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color(hex: "FF1E00"))
                        .foregroundColor(settingsManager.currentTheme.textColorOnPrimary)
                        .font(.system(size: settingsManager.textSizeSettings.subTitle))
                        .clipShape(Capsule())
                        .padding(10)
                    }
                }
                .offset(y: 5)
            }
            .padding()
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.bottom, 2)
    }
}

//#Preview {
//    InvitationCell(project: .init(id: "dsf", projectImage: "", projectName: "Project Name", roleRequired: "Role Required", requirement: "Что-то сделать", experience: "3 года", tools: "Фотошоп, Xcode", authorAvatar: "", authorName: "Никитос Кокос", ownerID: "sdv", description: ""))
//        .environmentObject(SettingsManager())
//}
