//
//  HomeView.swift
//  Collart
//
//  Created by Nik Y on 02.01.2024.
//

import SwiftUI
import CachedAsyncImage

enum Tab: Pickable, CaseIterable {
    case projects, specialists
    
    var displayValue: String {
        switch self {
        case .projects: return "Проекты"
        case .specialists: return "Специалисты"
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var selectedTab: Tab = .projects
    @State private var showFilters: Bool = false
    @State private var isFiltersFetched = false
    
    @State private var selectedProject: Order?
    @State private var isShowingDetailProject = false
    @State private var selectedSpecialists: Specialist?
    @State private var isShowingDetailSpecialist = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            if !isFiltersFetched {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                    .scaleEffect(3)
                    .onAppear {
                        NetworkService.fetchSkills { result in
                            switch result {
                            case .success(let skills):
                                viewModel.specialtyFilters = skills.map({ FilterOption(text: $0.text)})
                                isFiltersFetched = true
                            case .failure(let failure):
                                print("skills fetch error")
                                isFiltersFetched = true
                            }
                        }
                    }
            } else {
                VStack {
                    SearchBarPro(text: $searchText, showFilters: $showFilters)
                        .padding()
                    
                    CustomPicker(selectedTab: $selectedTab)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(viewModel.specialtyFilters, id: \.id) { filter in
                                FilterCell(isSelected: filter.isSelected, text: filter.text)
                                    .padding(.leading, filter == viewModel.specialtyFilters.first ? 10 : 0)
                                    .padding(.trailing, filter == viewModel.specialtyFilters.last ? 10 : 0)
                                    .onTapGesture {
                                        viewModel.selectSpecialty(filter)
                                        viewModel.applyFilters()
                                    }
                            }
                        }
                        // костылек, но LazyHStack не хочет нормально работать
                        .frame(height: settings.textSizeSettings.body + 30)
                    }
                    .animation(.default, value: viewModel.specialtyFilters)
                    
                    RefreshableScrollView(
                        loadingViewBackgroundColor: settings.currentTheme.backgroundColor,
                        onRefresh: { done in
                            switch selectedTab {
                            case .projects:
                                viewModel.fetchProjects(completion: done)
                            case .specialists:
                                viewModel.fetchSpecialists(completion: done)
                            }
                        },
                        progress: { state in
                            if state == .waiting {
                                Text("Pull to refresh")
                                    .foregroundColor(settings.currentTheme.textColorPrimary)
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                            }
                        }) {
                            LazyVStack {
                                if selectedTab == .projects {
                                    if viewModel.projects.isEmpty {
                                        Spacer(minLength: 50)
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                            .scaleEffect(3)
                                            .onAppear {
                                                viewModel.fetchProjects {}
                                            }
                                    } else {
                                        ForEach(viewModel.projects) { project in
                                            ProjectCell(project: project, onRespond: viewModel.handleResponse)
                                                .listRowSeparator(.hidden)
                                                .transition(.opacity)
                                        }
                                        .listRowBackground(Color.clear)
                                    }
                                } else {
                                    if viewModel.specialists.isEmpty {
                                        Spacer(minLength: 50)
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                            .scaleEffect(3)
                                            .onAppear {
                                                viewModel.fetchSpecialists {}
                                            }
                                    } else {
                                        ForEach(viewModel.specialists) { specialist in
                                            SpecialistCell(specialist: specialist, onRespond: {
                                                viewModel.handleInvite(spec: specialist)
                                            })
                                            .listRowSeparator(.hidden)
                                            .transition(.opacity)
                                            .onTapGesture {
                                                selectedSpecialists = specialist
                                                isShowingDetailSpecialist = true
                                            }
                                        }
                                        .listRowBackground(Color.clear)
                                    }
                                }
                            }
                            .padding()
                        }
                        .animation(.easeInOut, value: selectedTab)
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationDestination(isPresented: $isShowingDetailProject) {
                    if let project = selectedProject {
                        DetailProjectView(project: project)
                    }
                }
                .navigationDestination(isPresented: $isShowingDetailSpecialist) {
                    if let specialist = selectedSpecialists {
                        DetailSpecialitstView(viewModel: DetailSpecialitstViewModel(specProfile: specialist))
                    }
                }
                .sheet(isPresented: $showFilters) {
                    FiltersView(viewModel: viewModel, isActive: $showFilters)
                }
                .onChange(of: showFilters, perform: { newValue in
                    viewModel.applyFilters()
                })
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
                            isLoading = true
                            for selectedProjectsForInvite in viewModel.selectedProjectsForInvite {
                                NetworkService.Interactions.sendInvite(orderID: selectedProjectsForInvite.id, getterID: viewModel.selectedSpecialist?.id ?? "") { success, error in
                                    isLoading = false
                                    viewModel.showInviteSelect.toggle()
                                    viewModel.selectedProjectsForInvite = []
                                }
                            }
                            
                        } label: {
                            if isLoading {
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
            }
        }
    }
}

// MARK: - Components

// MARK: - Data Models

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SettingsManager())
            .preferredColorScheme(.dark)
    }
}

