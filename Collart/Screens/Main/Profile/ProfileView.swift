//
//  ProfileView.swift
//  Collart
//
//  Created by Nik Y on 17.03.2024.
//

import SwiftUI
import CachedAsyncImage

enum ProfileTab: Pickable, CaseIterable {
    case active, portfolio, collaborations, liked
    
    var displayValue: String {
        switch self {
        case .portfolio: return "Портфолио"
        case .collaborations: return "Коллаборации"
        case .active: return "Активные"
        case .liked: return "Избранные"
        }
    }
}

enum UserLoadingStatus: Int {
    case loading = 0
    case success = 1
    case error = 2
}

var isBackFromCreate = false

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab: ProfileTab = .active
    @State var isLoading = false
    @State var userLoading = UserLoadingStatus.loading
    let columns = [
        GridItem(.flexible(minimum: 0, maximum: .infinity)),
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]
    
    var body: some View {
        VStack {
            switch userLoading {
            case .loading:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                    .scaleEffect(3)
            case .error:
                Text("Ошибка при загрузке профиля пользователя")
                    .font(.system(size: settings.textSizeSettings.title))
                    .foregroundColor(settings.currentTheme.textDescriptionColor)
            case .success:
                VStack {
                    CachedAsyncImage(url: URL(string: !viewModel.specProfile.backgroundImage.isEmpty ? viewModel.specProfile.backgroundImage : "no url"), urlCache: .imageCache) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                .scaledToFill()
                        case .failure(_):
                            Image(systemName: "photo.artframe")
                                .resizable()
                                .scaledToFill()
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                        @unknown default:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                .scaledToFill()
                        }
                    }
                    .frame(height: 150)
                    .clipShape(Rectangle())
                    .foregroundColor(.black)
                    .overlay(alignment: .bottom) {
                        CachedAsyncImage(url: URL(string: !viewModel.specProfile.avatar.isEmpty ? viewModel.specProfile.avatar : "no url"), urlCache: .imageCache) { phase in
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
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .foregroundColor(.black)
                        .padding(5)
                        .background(settings.currentTheme.backgroundColor)
                        .clipShape(Circle())
                        .offset(y: 30)
                    }
                    .padding(.bottom)
                    
                    
                    VStack(spacing: 5) {
                        Text("\(viewModel.specProfile.name) \(viewModel.specProfile.surname)".trimmingCharacters(in: [" "]))
                            .font(.system(size: settings.textSizeSettings.pageName))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                            .bold()
                            .padding(.bottom, 1)
                        
                        Text(viewModel.specProfile.profession)
                            .font(.system(size: settings.textSizeSettings.title))
                            .foregroundColor(settings.currentTheme.textDescriptionColor)
                        
                        if !viewModel.specProfile.subProfessions.isEmpty {
                            Text(viewModel.specProfile.subProfessions.joined(separator: ", "))
                                .font(.system(size: settings.textSizeSettings.title))
                                .foregroundColor(settings.currentTheme.textDescriptionColor)
                                .multilineTextAlignment(.center)
                        }
                        
                        Text(viewModel.specProfile.email)
                            .font(.system(size: settings.textSizeSettings.title))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                        
                        CustomPicker(selectedTab: $selectedTab, expandsBeyondScreen: true)
                        
                        ScrollView {
                            switch selectedTab {
                            case .portfolio:
                                let test = viewModel.specProfile.portfolioProjects.isEmpty
                                if isLoading && viewModel.specProfile.portfolioProjects.isEmpty {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                                .scaleEffect(3)
                                            Spacer()
                                        }
                                        .padding(.top, 70)
                                        
                                    }
                                } else {
                                    LazyVGrid(columns: columns) {
                                        ForEach(viewModel.specProfile.portfolioProjects, id: \.id) { item in
                                            PortfolioCell(imageName: item.projectImage, title: item.projectName)
                                                .padding(5)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 10)
                                    .overlay {
                                        if viewModel.specProfile.portfolioProjects.isEmpty {
                                            Text("Нет проектов в портфолио")
                                        }
                                    }
                                }
                            case .collaborations:
                                if isLoading && viewModel.specProfile.oldProjects.isEmpty {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                                .scaleEffect(3)
                                            Spacer()
                                        }
                                        .padding(.top, 70)
                                    }
                                    
                                } else {
                                    LazyVStack(spacing: 20) {
                                        ForEach(viewModel.specProfile.oldProjects, id: \.id) { item in
                                            OldOrderCell(oldOrder: item)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal)
                                    .overlay {
                                        if viewModel.specProfile.oldProjects.isEmpty {
                                            Text("Нет активных коллабораций")
                                        }
                                    }
                                }
                            case .active:
                                if isLoading && viewModel.specProfile.activeProjects.isEmpty {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                                .scaleEffect(3)
                                            Spacer()
                                        }
                                        .padding(.top, 70)
                                    }
                                } else {
                                    LazyVStack(spacing: 20) {
                                        ForEach(viewModel.specProfile.activeProjects, id: \.id) { item in
                                            ProjectCell(project: item)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .overlay {
                                        if viewModel.specProfile.activeProjects.isEmpty {
                                            Text("Нет активных проектов")
                                        }
                                    }
                                }
                            case .liked:
                                if isLoading && viewModel.specProfile.liked.isEmpty {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                                .scaleEffect(3)
                                            Spacer()
                                        }
                                        .padding(.top, 70)
                                    }
                                } else {
                                    LazyVStack(spacing: 20) {
                                        ForEach(viewModel.specProfile.liked, id: \.id) { item in
                                            ProjectCell(project: item)
                                        }
                                        .padding(.vertical, 10)
                                    }
                                    .padding(.top, 5)
                                    .padding(.horizontal, 20)
                                    .overlay {
                                        if viewModel.specProfile.liked.isEmpty {
                                            Text("Нет избранных проектов")
                                        }
                                    }
                                }
                            }
                        }
                        .animation(.easeInOut, value: selectedTab)
                    }
                    .background(settings.currentTheme.backgroundColor)
                    .navigationBarBackButtonHidden()
                    .overlay(alignment: .bottomTrailing) {
                        switch selectedTab {
                        case .active, .portfolio:
                            NavigationLink {
                                if case .active = selectedTab {
                                    CreateOrderView()
                                } else if case .portfolio = selectedTab {
                                    CreatePortfolioView()
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .padding(20)
                                    .foregroundColor(settings.currentTheme.textColorOnPrimary)
                                    .background(settings.currentTheme.primaryColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 25.0))
                                    .shadow(radius: 1)
                                    .padding()
                            }
                            .animation(.default, value: selectedTab)
                        default:
                            Spacer()
                        }
                    }
                }
                .overlay(alignment: .topTrailing) {
                    NavigationLink {
                        EditProfileView(user: UserManager.shared.user)
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32)
                            .bold()
                            .foregroundColor(settings.currentTheme.backgroundColor)
                            .shadow(radius: 2)
                            .rotationEffect(.degrees(90))
                    }
                    .padding(10)
                    .padding(.vertical)
                    .padding(.bottom, 5)
                    .onTapGesture {
                        print("open settings")
                        // open settings
                    }
                }

            }
        }
        .onAppear {            
            userLoading = .loading
            viewModel.fetchUser { success in
                if success {
                    userLoading = .success
                    loadData(for: selectedTab)
                } else {
                    userLoading = .error
                }
            }
        }
        .onChange(of: selectedTab) { newTab in
            loadData(for: newTab)
        }
    }
    
    private func loadData(for tab: ProfileTab) {
            isLoading = true
            switch tab {
            case .portfolio:
                NetworkService.fetchPortfolio(userId: viewModel.specProfile.id) { result in
                    switch result {
                    case .success(let portfolioProjects):
                        viewModel.specProfile.portfolioProjects = portfolioProjects.map({ proj in
                            PortfolioProject(projectImage: proj.image, projectName: proj.name, files: proj.files)
                        })
                    case .failure(let error):
                        print("Error fetching portfolio: \(error.localizedDescription)")
                    }
                    isLoading = false
                }
            case .collaborations:
                NetworkService.fetchCompletedCollaborations(userId: viewModel.specProfile.id) { result in
                    switch result {
                    case .success(let projects):
                        NetworkService.Interactions.fetchUserInteractions(userId: viewModel.specProfile.id) { result in
                            switch result {
                            case .success(let interactions):
                                viewModel.specProfile.oldProjects = []
                                for proj in projects {
                                    var contributors: [Specialist] = []
                                    for interaction in interactions {
                                        if interaction.order.order.id == proj.order.id {
                                            if !contributors.contains(where: { spec in
                                                spec.id == interaction.getter.user.id
                                            }) {
                                                // Добавить геттера в контрибуторы
                                                contributors.append(Specialist.transformToSpecialist(from: interaction.getter))
                                            }
                                            
                                            if !contributors.contains(where: { spec in
                                                spec.id == interaction.sender.user.id
                                            }) {
                                                // Добавить sender в контрибуторы
                                                contributors.append(Specialist.transformToSpecialist(from: interaction.sender))
                                            }
                                        }
                                    }
                                    viewModel.specProfile.oldProjects.append(OldProject(contributors: contributors, project: Order.transformToOrder(from: proj)))
                                }
                            case .failure(let failure):
                                break
                            }
                            isLoading = false
                        }
                    case .failure(let error):
                        print("Error fetching portfolio: \(error.localizedDescription)")
                        isLoading = false
                    }
                }
            case .active:
                NetworkService.fetchUserOrders(userId: viewModel.specProfile.id) { result in
                    switch result {
                    case .success(let projects):
                        let projs = projects.map({ proj in
                            Order.transformToOrder(from: proj)
                        })
                        viewModel.specProfile.activeProjects = projs
                        UserManager.shared.user.activeProjects = projs
                    case .failure(let error):
                        print("Error fetching portfolio: \(error.localizedDescription)")
                    }
                    isLoading = false
                }
            case .liked:
                NetworkService.fetchFavorites(userId: viewModel.specProfile.id) { result in
                    switch result {
                    case .success(let projects):
                        let projs = projects.map({ proj in
                            Order.transformToOrder(from: proj)
                        })
                        viewModel.specProfile.liked = projs
                        UserManager.shared.user.liked = projs
                    case .failure(let error):
                        print("Error fetching portfolio: \(error.localizedDescription)")
                    }
                    isLoading = false
                }
            }
        }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SettingsManager())
    }
}
