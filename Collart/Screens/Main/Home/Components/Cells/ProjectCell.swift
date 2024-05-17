//
//  ProjectCell.swift
//  Collart
//
//  Created by Nik Y on 17.02.2024.
//

import SwiftUI
import CachedAsyncImage

struct ProjectCell: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State var isAvailable: Bool = true
    @State var isShowingDetailProject = false
    @State private var isFavorite: Bool = false
    var project: Order
    var onRespond: ((_ project: Order, _ completion: @escaping () -> ()) -> ())?

    @State private var isLoading = false
    
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
            .contentShape(Rectangle())
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(project.projectName)
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                        .padding(.bottom, 1)
                    
                    Spacer()
                    
                    Button(action: {
                        toggleFavoriteStatus()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(isFavorite ? .red : settingsManager.currentTheme.textColorPrimary)
                    }
                }
                
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
                    
                    Text(project.authorName)
                        .font(.system(size: settingsManager.textSizeSettings.body))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                }
                .padding(.bottom, 10)

                if project.ownerID != UserManager.shared.user.id {
                    Button {
                        print("button tap")
                        if isAvailable {
                            isLoading = true
                            onRespond?(project) {
                                print("tap button \(project.projectName)")
                                isAvailable.toggle()
                                isLoading = false
                            }
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isAvailable ? "Откликнуться" : "Заявка отправлена")
                        }
                    }
                    .buttonStyle(ConditionalButtonStyle(conditional: isAvailable))
                    .disabled(!isAvailable)
                }
            }
            .padding()
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .onTapGesture {
            isShowingDetailProject = true
        }
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.bottom, 2)
        .navigationDestination(isPresented: $isShowingDetailProject) {
            DetailProjectView(project: project)
        }
        .onAppear {
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
                    UserManager.shared.user.liked.append(project)
                    isFavorite = true
                }
            }
        }
    }
}


//struct ProjectCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectCell()
//            .environmentObject(SettingsManager())
//    }
//}
