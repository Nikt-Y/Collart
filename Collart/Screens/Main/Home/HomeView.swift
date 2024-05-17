//
//  HomeView.swift
//  Collart
//

import SwiftUI
import CachedAsyncImage

// MARK: - Tab
enum Tab: Pickable, CaseIterable {
    case projects, specialists
    
    var displayValue: String {
        switch self {
        case .projects: return "Проекты"
        case .specialists: return "Специалисты"
        }
    }
}

// MARK: - HomeView
struct HomeView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: Tab = .projects
    @State private var showFilters: Bool = false
    @State private var isFiltersFetched = false
    
    @State private var selectedProject: Order?
    @State private var isShowingDetailProject = false
    @State private var selectedSpecialists: Specialist?
    @State private var isShowingDetailSpecialist = false
    @State private var isSendingInvites = false
    
    var body: some View {
        NavigationStack {
            if !isFiltersFetched {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                    .scaleEffect(3)
                    .onAppear {
                        viewModel.fetchSkills { success in
                            isFiltersFetched = success
                        }
                    }
            } else {
                VStack {
                    SearchBarPro(text: $viewModel.searchText, showFilters: $showFilters)
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
                        .frame(height: settings.textSizeSettings.body + 30)
                    }
                    .animation(.default, value: viewModel.specialtyFilters)
                    
                    RefreshableScrollView(
                        loadingViewBackgroundColor: settings.currentTheme.backgroundColor,
                        onRefresh: { done in
                            viewModel.fetchData(for: selectedTab, completion: done)
                        },
                        progress: { state in
                            if state == .waiting {
                                Image("arrowDown")
                                    .foregroundColor(settings.currentTheme.textColorPrimary)
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                            }
                        }) {
                            LazyVStack {
                                if selectedTab == .projects {
                                    if viewModel.isLoading {
                                        Spacer(minLength: 50)
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                            .scaleEffect(3)
                                    } else {
                                        if viewModel.filteredOrders.isEmpty {
                                            Text("Проекты не найдены")
                                                .padding()
                                                .padding(.top, 50)
                                        } else {
                                            ForEach(viewModel.filteredOrders) { project in
                                                ProjectCell(project: project, onRespond: viewModel.handleResponse)
                                                    .listRowSeparator(.hidden)
                                                    .transition(.opacity)
                                            }
                                            .listRowBackground(Color.clear)
                                        }
                                    }
                                } else {
                                    if viewModel.isLoading {
                                        Spacer(minLength: 50)
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                                            .scaleEffect(3)
                                    } else {
                                        if viewModel.filteredSpecs.isEmpty {
                                            Text("Специалисты не найдены")
                                                .padding()
                                                .padding(.top, 50)
                                        } else {
                                            ForEach(viewModel.filteredSpecs) { specialist in
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
                            }
                            .padding()
                        }
                        .animation(.easeInOut, value: selectedTab)
                        .onChange(of: selectedTab) { newValue in
                            viewModel.isLoading = true
                            if newValue == .projects {
                                viewModel.fetchProjects {
                                }
                            } else {
                                viewModel.fetchSpecialists {
                                }
                            }
                        }
                        .onAppear {
                            viewModel.isLoading = true
                            viewModel.fetchData(for: .projects) {
//                                viewModel.isLoading = false
                            }
                        }
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .background(settings.currentTheme.backgroundColor)
                .navigationDestination(isPresented: $isShowingDetailProject) {
                    if let project = selectedProject {
                        DetailProjectView(project: project)
                    }
                }
                .navigationDestination(isPresented: $isShowingDetailSpecialist) {
                    if let specialist = selectedSpecialists {
                        DetailSpecialistView(viewModel: DetailSpecialistViewModel(specProfile: specialist))
                    }
                }
                .sheet(isPresented: $showFilters) {
                    FiltersView(viewModel: viewModel, isActive: $showFilters)
                        .ignoresSafeArea(.keyboard, edges: .bottom)

                }
                .onChange(of: showFilters, perform: { newValue in
                    viewModel.applyFilters()
                })
                .sheet(isPresented: $viewModel.showInviteSelect, content: {
                    InviteSelectionView(viewModel: viewModel, isSendingInvites: $isSendingInvites)
                })
            }
        }
    }
}
