//
//  DetailSpecialitstView.swift
//  Collart
//
//  Created by Nik Y on 20.03.2024.
//

import SwiftUI
import CachedAsyncImage

enum DetailSpecTab: Pickable, CaseIterable {
    case portfolio, collaborations, active
    
    var displayValue: String {
        switch self {
        case .portfolio: return "Портфолио"
        case .collaborations: return "Коллаборации"
        case .active: return "Активные"
            //        case .liked: return "Избранные"
        }
    }
}

struct DetailSpecialitstView: View {
    @StateObject var viewModel: DetailSpecialitstViewModel
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    var isProfile: Bool = false
    @State private var selectedTab: DetailSpecTab = .portfolio
    @State var loadingInvite = false
    @State var isLoading = false
    let columns = [
        GridItem(.flexible(minimum: 0, maximum: .infinity)),
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]
    
    var body: some View {
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
            
            
            VStack(spacing: 0) {
                Text(viewModel.specProfile.name)
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
                }
                
                Text(viewModel.specProfile.email)
                    .font(.system(size: settings.textSizeSettings.title))
                    .foregroundColor(settings.currentTheme.textColorPrimary)
                
                if !isProfile {
                    HStack {
                        Button("Написать") {
                            // action
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .padding()
                        
                        Button("Пригласить") {
                            viewModel.showInviteSelect = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding()
                    }
                    
                }
                
                CustomPicker(selectedTab: $selectedTab)
                ScrollView {
                    switch selectedTab {
                    case .portfolio:
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
                            .padding(.top, 5)
                            .padding(.horizontal, 10)
                            
                            .onAppear {
                                isLoading = true
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
                            .padding(.top, 5)
                            .padding(.horizontal)
                            
                            .onAppear {
                                isLoading = true
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
                                                    viewModel.specProfile.oldProjects.append( OldProject(contributors: contributors, project: Order.transformToOrder(from: proj)))
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
                            .padding(.top, 5)
                            .padding(.horizontal, 20)
                            
                            .onAppear {
                                isLoading = true
                                NetworkService.fetchUserOrders(userId: viewModel.specProfile.id) { result in
                                    switch result {
                                    case .success(let projects):
                                        viewModel.specProfile.activeProjects = projects.map({ proj in
                                            Order.transformToOrder(from: proj)
                                        })
                                    case .failure(let error):
                                        print("Error fetching portfolio: \(error.localizedDescription)")
                                    }
                                    isLoading = false
                                }
                            }
                        }
                    }
                }
                .animation(.easeInOut, value: selectedTab)
                
            }
            
        }
        .background(settings.currentTheme.backgroundColor)
        .sheet(isPresented: $viewModel.showInviteSelect, content: {
            VStack {
                Text("Выберите проект для приглашения")
                    .multilineTextAlignment(.center)
                    .font(.system(size: settings.textSizeSettings.pageName))
                    .foregroundColor(settings.currentTheme.textColorPrimary)
                    .bold()
                    .padding(.horizontal, 40)
                    .padding(.vertical, 20)
                
                List(UserManager.shared.user.activeProjects) { item in
                    GeometryReader(content: { geometry in
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
                                case .failure(_):
                                    Image(systemName: "photo.artframe")
                                        .resizable()
                                        .aspectRatio(16/9, contentMode: .fill)
                                        .foregroundColor(settings.currentTheme.textColorPrimary)
                                @unknown default:
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                }
                            }
                            .frame(width: geometry.size.width/6)
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
                    })
                }
                .listStyle(.plain)
                .overlay(Group {
                    if UserManager.shared.user.activeProjects.isEmpty {
                        Text("У вас нет проектов для приглашения")
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                    }
                })
                
                
                Button {
                    loadingInvite = true
                    for selectedProjectsForInvite in viewModel.selectedProjectsForInvite {
                        NetworkService.Interactions.sendInvite(orderID: selectedProjectsForInvite.id, getterID: viewModel.specProfile.id) { success, error in
                            loadingInvite = false
                            viewModel.showInviteSelect.toggle()
                            viewModel.selectedProjectsForInvite = []
                        }
                    }
                    
                } label: {
                    if loadingInvite {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Пригласить")
                    }
                }
                .buttonStyle(ConditionalButtonStyle(conditional: !viewModel.selectedProjectsForInvite.isEmpty))
                .disabled(viewModel.selectedProjectsForInvite.isEmpty)
                .padding(.horizontal)
                //                    Button("Пригласить") {
                //                        viewModel.showInviteSelect.toggle()
                //                        viewModel.selectedProjectsForInvite = []
                //                    }
                //                    .buttonStyle(ConditionalButtonStyle(conditional: !viewModel.selectedProjectsForInvite.isEmpty))
                //                    .disabled(viewModel.selectedProjectsForInvite.isEmpty)
                //                    .padding(.horizontal)
            }
            .presentationDetents([.medium])
        })
        .navigationBarBackButtonHidden()
        .overlay(alignment: .topLeading) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundColor(settings.currentTheme.backgroundColor)
                    .shadow(radius: 2)
                    .padding(10)
            }
        }
    }
}

//struct DetailSpecialitstView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailSpecialitstView(viewModel: DetailSpecialitstViewModel(specProfile: User(id: "df")))
//            .environmentObject(SettingsManager())
//    }
//}
