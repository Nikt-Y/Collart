//
//  HomeView.swift
//  Collart
//
//  Created by Nik Y on 02.01.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var selectedTab: Tab = .projects
    @State private var showFilters: Bool = false
    
    @State private var selectedProject: Project?
    @State private var isShowingDetailProject = false
    @State private var selectedSpecialists: Specialist?
    @State private var isShowingDetailSpecialist = false
    
    var body: some View {
        NavigationStack {
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
                                }
                        }
                    }
                    // костылек, но LazyHStack не хочет нормально работать
                    .frame(height: settings.textSizeSettings.body + 30)
                }
                .animation(.default, value: viewModel.specialtyFilters)
                
                List {
                    if selectedTab == .projects {
                        ForEach(viewModel.projects) { project in
                            ProjectCell(project: project)
                                .listRowSeparator(.hidden)
                                .transition(.opacity)
                                .onTapGesture {
                                    isShowingDetailProject = true
                                    selectedProject = project
                                }
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.specialists) { specialist in
                            SpecialistCell(specialist: specialist)
                                .listRowSeparator(.hidden)
                                .transition(.opacity)
                                .onTapGesture {
                                    isShowingDetailSpecialist = true
                                    selectedSpecialists = specialist
                                }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .animation(.easeInOut, value: selectedTab)
                .listStyle(.plain)
                .onAppear {
                    viewModel.fetchDataWithFilters()
                }
            }
            .background(settings.currentTheme.backgroundColor)
            .navigationDestination(isPresented: $isShowingDetailProject) {
                if let project = selectedProject {
                    DetailProjectView(project: project)
                }
            }
            .navigationDestination(isPresented: $isShowingDetailSpecialist) {
                if let specialist = selectedSpecialists {
                    DetailSpecialitstView(specialist: specialist)
                }
            }
            .sheet(isPresented: $showFilters) {
                FiltersView(viewModel: viewModel, isActive: $showFilters)
            }
        }
    }
}

// MARK: - Components

struct CategoryView: View {
    let category: Category
    
    var body: some View {
        Text(category.rawValue)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(15)
    }
}

// MARK: - Data Models

enum Tab {
    case projects, specialists
}

enum Category: String, CaseIterable {
    case sound = "Sound"
    case photography = "Photography"
    case threeD = "3D"
    case illustration = "Illustration"
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SettingsManager())
            .preferredColorScheme(.dark)
    }
}

