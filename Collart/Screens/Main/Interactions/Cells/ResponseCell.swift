//
//  ResponseCell.swift
//  Collart
//
//  Created by Nik Y on 28.03.2024.
//

import SwiftUI
import CachedAsyncImage

struct ResponseCell: View {
    @EnvironmentObject var settingsManager: SettingsManager
    
    var id: String
    var responser: User
    var project: Order
    
    @State var status: InteractionStatus
    @State var rejectLoading = false
    @State var acceptLoading = false
    
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
                .clipped()
            
            HStack {
                CachedAsyncImage(url: URL(string: !responser.avatar.isEmpty ? responser.avatar : "no url"), urlCache: .imageCache) { phase in
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
                    .background(settingsManager.currentTheme.backgroundColor)
                    .clipShape(Circle())
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(settingsManager.currentTheme.backgroundColor, lineWidth: 2))
                
                Text("\(responser.name) откликнулся на Ваш проект \(project.projectName)!")
                    .font(.system(size: settingsManager.textSizeSettings.subTitle))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .padding(.vertical, 4)
                
                
                Spacer()
                
            }
            .padding(.horizontal)
            .padding(.top, 5)
            
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
                    Button("Коллаборация начата!") {
//                        status = .active
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
                    Button("Коллаборация отменена") {
//                        status = .active
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
            .padding(.horizontal, 10)
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 5)
        .padding(.bottom, 2)
    }
}

//#Preview {
//    ResponseCell(responser: User(id: "zc"), project: .init(id:"sdf", projectImage: "", projectName: "Project Name", roleRequired: "Role Required", requirement: "Что-то сделать", experience: "3 года", tools: "Фотошоп, Xcode", authorAvatar: "", authorName: "Никитос Кокос", ownerID: "dfs", description: ""))
//        .environmentObject(SettingsManager())
//}
