//
//  DetailProjectView.swift
//  Collart
//
//  Created by Nik Y on 13.03.2024.
//

import SwiftUI
import CachedAsyncImage

struct DetailProjectView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    @State private var isFavorite: Bool = false
    
    let project: Order
    
    init(project: Order) {
        self.project = project
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
                        CachedAsyncImage(url: URL(string: !project.authorAvatar.isEmpty ? project.authorAvatar : "no url"), urlCache: .imageCache) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                            case .failure(_):
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(settings.currentTheme.textColorPrimary)
                            @unknown default:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                            }
                        }
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                        
                        Text(project.authorName)
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    CachedAsyncImage(url: URL(string: !project.projectImage.isEmpty ? project.projectImage : "no url"), urlCache: .imageCache) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                        case .failure(_):
                            Image(systemName: "photo.artframe")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                        @unknown default:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                        }
                    }
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
            
            if project.ownerID != UserManager.shared.user.id {
                HStack {
                    NavigationLink {
                        ChatView(
                            specId: project.ownerID,
                            specImage: project.authorAvatar,
                            specName: project.authorName
                        )
                    } label: {
                        Text("Написать")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal)
                    .padding(.vertical, 7)
                    
                    Button("Откликнуться") {
                    }
                    .buttonStyle(ConditionalButtonStyle(conditional: true))
                    .padding(.horizontal)
                    .padding(.vertical, 7)
                }
            }
        }
        .background(settings.currentTheme.backgroundColor)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .foregroundColor(settings.currentTheme.textColorPrimary)
                                    .bold()
                            }
                        }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if project.ownerID != UserManager.shared.user.id {
                    Button(action: {
                        toggleFavoriteStatus()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(isFavorite ? .red : settings.currentTheme.textColorPrimary)
                    }
                } else {
                    Button(action: {
                        deleteOrder()
                    }) {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            let test = UserManager.shared.user.liked
            isFavorite = UserManager.shared.user.liked.contains { $0.id == project.id }
        }
    }
    
    private func toggleFavoriteStatus() {
        if isFavorite {
            NetworkService.removeOrderFromFavorites(orderId: project.id) { success, error in
                if success {
                    UserManager.shared.user.liked.removeAll { $0.id == project.id }
                    isFavorite = false
                }
            }
        } else {
            NetworkService.addOrderToFavorites(orderId: project.id) { success, error in
                if success {
                    DispatchQueue.main.async {
                        UserManager.shared.user.liked.append(project)
                        isFavorite = true
                    }
                }
            }
        }
    }
    
    private func deleteOrder() {
        NetworkService.deleteOrder(orderId: project.id) { success, error in
            DispatchQueue.main.async {
                ToastManager.shared.show(message: "Проект успешно удален")
                dismiss()
            }
        }
    }
}


//struct DetailProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailProjectView(project: Project(projectImage:  "https://example.com/projectImage1.png", projectName: "ZULI POSADA", roleRequired: "Графический дизайнер", requirement: "отрисовка логотипа по ТЗ", experience: "от 2 лет", tools: "Adobe Illustrator, Figma", authorAvatar: "https://example.com/authorAvatar1.png", authorName: "Jane Kudrinskaia", description: "lorem snk snd lkm sdf fnghfdh jngfdh jdfng kdjfng kjndf kgdkfjn kjngdf kjngdf kjngfd kjndfg kjndgf kjndfg kjngdf kjdnf f!"))
//            .environmentObject(SettingsManager())
//    }
//}
