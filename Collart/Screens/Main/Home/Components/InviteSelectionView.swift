//
//  InviteSelectionView.swift
//  Collart
//

import SwiftUI
import CachedAsyncImage

// MARK: - InviteSelectionView
struct InviteSelectionView: View {
    @Environment(\.networkService) private var networkService: NetworkService
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isSendingInvites: Bool
    @EnvironmentObject private var settings: SettingsManager

    private var interactionsService: InteractionsServiceDelegate {
        networkService
    }
    
    var body: some View {
        VStack {
            Text("Выберите проект для приглашения")
                .multilineTextAlignment(.center)
                .font(.system(size: settings.textSizeSettings.pageName))
                .foregroundColor(settings.currentTheme.textColorPrimary)
                .bold()
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            
            List(UserManager.shared.user.activeProjects) { item in
                GeometryReader { geometry in
                    HStack {
                        CachedAsyncImage(url: URL(string: !item.projectImage.isEmpty ? item.projectImage : "no url"), urlCache: .imageCache) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(16/9, contentMode: .fill)
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                            case .failure:
                                Image(systemName: "photo.artframe")
                                    .resizable()
                                    .aspectRatio(16/9, contentMode: .fill)
                                    .foregroundColor(settings.currentTheme.textColorPrimary)
                            @unknown default:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                            }
                        }
                        .frame(width: geometry.size.width / 6)
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .background()
                        .shadow(radius: 1)
                        
                        VStack {
                            Text(item.projectName)
                                .font(.system(size: settings.textSizeSettings.body))
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                        }
                        Spacer()
                        
                        if viewModel.selectedProjectsForInvite.contains(where: { $0.id == item.id }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .background()
                    .onTapGesture {
                        if viewModel.selectedProjectsForInvite.contains(where: { $0.id == item.id }) {
                            viewModel.selectedProjectsForInvite.removeAll { $0.id == item.id }
                        } else {
                            viewModel.selectedProjectsForInvite.append(item)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .overlay(Group {
                if UserManager.shared.user.activeProjects.isEmpty {
                    Text("У вас нет проектов для приглашения")
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                }
            })
            
            Button {
                isSendingInvites = true
                for selectedProject in viewModel.selectedProjectsForInvite {
                    interactionsService.sendInvite(orderID: selectedProject.id, getterID: viewModel.selectedSpecialist?.id ?? "") { success, error in
                        isSendingInvites = false
                        viewModel.showInviteSelect.toggle()
                        viewModel.selectedProjectsForInvite = []
                    }
                }
                
            } label: {
                if isSendingInvites {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Пригласить")
                }
            }
            .buttonStyle(ConditionalButtonStyle(conditional: !viewModel.selectedProjectsForInvite.isEmpty))
            .disabled(viewModel.selectedProjectsForInvite.isEmpty)
            .padding(.horizontal)
        }
        .presentationDetents([.medium])
    }
}

