//
//  HomeViewModel.swift
//  Collart
//

import Foundation
import SwiftUI

// MARK: - FilterOption
struct FilterOption: Identifiable, Hashable {
    var id: String { text }
    let text: String
    var isSelected: Bool = false
}

// MARK: - HomeViewModel
class HomeViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var projects: [Order] = []
    @Published var specialists: [Specialist] = []
    var projectList: [Order] = []
    var specialistList: [Specialist] = []
    
    // Sending project invitations
    @Published var showInviteSelect: Bool = false
    @Published var selectedProjectsForInvite: [Order] = []
    @Published var selectedSpecialist: Specialist?
    
    // Filters for specialties, experience and tools
    @Published var specialtyFilters: [FilterOption] = []
    @Published var experienceFilters: [FilterOption] = []
    @Published var toolFilters: [FilterOption] = []
    
    // Search
    @Published var searchText = ""
    @Published var specialtySearchText = ""
    @Published var experienceSearchText = ""
    @Published var toolSearchText = ""
    
    @Published var isLoading = true
    
    private var networkServiceDelegate: SkillsServiceDelegate & SearchServiceDelegate & InteractionsServiceDelegate {
        networkService
    }
    
    init() {
        loadFilters()
    }
    
    func handleResponse(for project: Order, completion: @escaping () -> ()) {
        networkServiceDelegate.responce(orderID: project.id, ownerId: project.ownerID) { success, error in
            completion()
        }
    }
    
    func handleInvite(spec: Specialist) {
        selectedSpecialist = spec
        showInviteSelect.toggle()
        print("Откликнулся на проект \(spec.name)")
    }
    
    func loadFilters() {
        toolFilters = [
            .init(text: "Postman", isSelected: false),
            .init(text: "Adobe Photoshop", isSelected: false),
            .init(text: "Adobe Illustrator", isSelected: false),
            .init(text: "Adobe InDesign", isSelected: false),
            .init(text: "Sketch", isSelected: false),
            .init(text: "Figma", isSelected: false),
            .init(text: "Blender", isSelected: false),
            .init(text: "Autodesk Maya", isSelected: false),
            .init(text: "Affinity Designer", isSelected: false),
            .init(text: "CorelDRAW", isSelected: false),
            .init(text: "Adobe XD", isSelected: false),
            .init(text: "Cinema 4D", isSelected: false),
            .init(text: "InVision", isSelected: false),
            .init(text: "Xcode", isSelected: false),
            .init(text: "Visual Studio Code", isSelected: false),
            .init(text: "Docker", isSelected: false),
            .init(text: "PostgresSQL", isSelected: false),
            .init(text: "Node.js", isSelected: false),
            .init(text: "MongoDB", isSelected: false),
            .init(text: "React", isSelected: false),
            .init(text: "Unity", isSelected: false),
            .init(text: "Angular", isSelected: false),
            .init(text: "Firebase", isSelected: false),
            .init(text: "Laravel", isSelected: false),
            .init(text: "Vue.js", isSelected: false),
            .init(text: "Zoom API", isSelected: false)
        ]
        experienceFilters = [.init(text: "Нет опыта", isSelected: false), .init(text: "От 1 года до 3 лет", isSelected: false) , .init(text: "От 3 до 5 лет"), .init(text: "Более 5 лет")]
    }
    
    func fetchSkills(completion: @escaping (Bool) -> Void) {
        networkServiceDelegate.fetchSkills { result in
            switch result {
            case .success(let skills):
                self.specialtyFilters = skills.map { FilterOption(text: $0.text) }
                completion(true)
            case .failure:
                print("skills fetch error")
                completion(true)
            }
        }
    }
    
    func fetchProjects(completion: @escaping () -> Void) {
        networkServiceDelegate.fetchListOfOrders { result in
            switch result {
            case .success(let orders):
                print("Orders: \(orders)")
                self.projectList = orders.map { Order.transformToOrder(from: $0) }
                self.applyFilters()
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    func fetchSpecialists(completion: @escaping () -> Void) {
        let language = UserDefaults.standard.string(forKey: "language") ?? "ru"
        networkServiceDelegate.fetchListOfUsers { result in
            switch result {
            case .success(let users):
                self.specialistList = users.map { Specialist.transformToSpecialist(from: $0) }
                print("users: \(users)")
                self.applyFilters()
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    func fetchData(for tab: Tab, completion: @escaping () -> Void) {
        isLoading = true
        switch tab {
        case .projects:
            fetchProjects {
                completion()
            }
        case .specialists:
            fetchSpecialists {
                completion()
            }
        }
    }
    
    // Functions for updating the selected state
    func selectSpecialty(_ option: FilterOption) {
        if let index = specialtyFilters.firstIndex(where: { $0.id == option.id }) {
            specialtyFilters[index].isSelected.toggle()
        }
        sortSelectedSpecialties()
    }
    
    func selectExperience(_ option: FilterOption) {
        if let index = experienceFilters.firstIndex(where: { $0.id == option.id }) {
            experienceFilters[index].isSelected.toggle()
        }
        sortSelectedExperiences()
    }
    
    func selectTool(_ option: FilterOption) {
        if let index = toolFilters.firstIndex(where: { $0.id == option.id }) {
            toolFilters[index].isSelected.toggle()
        }
        sortSelectedTools()
    }
    
    // Functions for sorting selected filters
    func sortSelectedSpecialties() {
        specialtyFilters.sort { $0.isSelected && !$1.isSelected }
    }
    
    func sortSelectedExperiences() {
        experienceFilters.sort { $0.isSelected && !$1.isSelected }
    }
    
    func sortSelectedTools() {
        toolFilters.sort { $0.isSelected && !$1.isSelected }
    }
    
    var filteredSpecialtyFilters: [FilterOption] {
        specialtyFilters.filter { specialtySearchText.isEmpty || $0.text.localizedCaseInsensitiveContains(specialtySearchText) }
    }
    
    var filteredExperienceFilters: [FilterOption] {
        experienceFilters.filter { experienceSearchText.isEmpty || $0.text.localizedCaseInsensitiveContains(experienceSearchText) }
    }
    
    var filteredToolFilters: [FilterOption] {
        toolFilters.filter { toolSearchText.isEmpty || $0.text.localizedCaseInsensitiveContains(toolSearchText) }
    }
    
    var isFiltersSelected: Bool {
        specialtyFilters.contains { $0.isSelected } ||
        experienceFilters.contains { $0.isSelected } ||
        toolFilters.contains { $0.isSelected }
    }
    
    var filteredOrders: [Order] {
        projects.filter { order in
            return searchText.isEmpty || order.projectName.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var filteredSpecs: [Specialist] {
        specialists.filter { spec in
            return searchText.isEmpty || spec.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func resetFilters() {
        specialtyFilters = specialtyFilters.map { FilterOption(text: $0.text, isSelected: false) }
        experienceFilters = experienceFilters.map { FilterOption(text: $0.text, isSelected: false) }
        toolFilters = toolFilters.map { FilterOption(text: $0.text, isSelected: false) }
    }
    
    func applyFilters() {
        let selectedSpecialties = specialtyFilters.filter { $0.isSelected }.map { $0.text }
        let selectedExperiences = experienceFilters.filter { $0.isSelected }.map { $0.text }
        let selectedTools = toolFilters.filter { $0.isSelected }.map { $0.text }
        
        let filteredProjects = projectList.filter { project in
            let matchesSpecialty = selectedSpecialties.isEmpty || selectedSpecialties.contains(where: project.roleRequired.contains)
            let matchesExperience = selectedExperiences.isEmpty || selectedExperiences.contains(where: project.experience.contains)
            let matchesTools = selectedTools.isEmpty || selectedTools.contains(where: project.tools.contains)
            
            return matchesSpecialty && matchesExperience && matchesTools
        }
        
        let filteredSpecs = specialistList.filter { specialist in
            let matchesProfession = selectedSpecialties.isEmpty || selectedSpecialties.contains(where: specialist.profession.contains)
            let matchesExperience = selectedExperiences.isEmpty || selectedExperiences.contains(where: specialist.experience.contains)
            let matchesTools = selectedTools.isEmpty || selectedTools.contains(where: specialist.tools.contains)
            
            return matchesProfession && matchesExperience && matchesTools
        }
        projects = []
        specialists = []
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.projects = filteredProjects
            self.specialists = filteredSpecs
            self.isLoading = false
        }
    }
}
