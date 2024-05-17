//
//  DetailProjectView.swift
//  Collart
//

import SwiftUI
import CachedAsyncImage

struct DetailProjectView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: DetailProjectViewModel
    
    init(project: Order) {
        _viewModel = StateObject(wrappedValue: DetailProjectViewModel(project: project))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.project.roleRequired)
                        .font(.system(size: settings.textSizeSettings.pageName))
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                        .bold()
                        .padding(.horizontal)
                    
                    HStack {
                        CachedAsyncImage(url: URL(string: !viewModel.project.authorAvatar.isEmpty ? viewModel.project.authorAvatar : "no url"), urlCache: .imageCache) { phase in
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
                        
                        Text(viewModel.project.authorName)
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    CachedAsyncImage(url: URL(string: !viewModel.project.projectImage.isEmpty ? viewModel.project.projectImage : "no url"), urlCache: .imageCache) { phase in
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
                        Text(viewModel.project.projectName)
                            .font(.system(size: settings.textSizeSettings.subTitle))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                            .bold()
                        
                        Text("Что требуется: \(viewModel.project.requirement)")
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Text("Опыт работы: \(viewModel.project.experience)")
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Text("Программы: \(viewModel.project.tools)")
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Text("О проекте:")
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        Text(viewModel.project.description)
                            .font(.system(size: settings.textSizeSettings.body))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                    }
                    .padding(.horizontal)
                    
                    if !viewModel.project.files.isEmpty {
                        HStack {
                            Image("file")
                                .resizable()
                                .foregroundColor(settings.currentTheme.primaryColor)
                                .frame(width: 30, height: 30)
                            
                            Text("Дополнительные файлы")
                                .font(.system(size: settings.textSizeSettings.body))
                                .foregroundColor(settings.currentTheme.primaryColor)
                                .underline()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            if viewModel.project.ownerID != UserManager.shared.user.id {
                HStack {
                    NavigationLink {
                        DetailChatView(
                            specId: viewModel.project.ownerID,
                            specImage: viewModel.project.authorAvatar,
                            specName: viewModel.project.authorName
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
                if viewModel.project.ownerID != UserManager.shared.user.id {
                    Button(action: {
                        viewModel.toggleFavoriteStatus()
                    }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(viewModel.isFavorite ? .red : settings.currentTheme.textColorPrimary)
                    }
                } else {
                    Button(action: {
                        viewModel.deleteOrder {
                            dismiss()
                        }
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
            viewModel.checkIfFavorite()
        }
    }
}
