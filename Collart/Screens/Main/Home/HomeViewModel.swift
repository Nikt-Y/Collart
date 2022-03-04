//
//  HomeViewModel.swift
//  Collart
//
//  Created by Nik Y on 15.02.2024.
//

import Foundation

struct FilterOption: Identifiable, Hashable {
    var id: String { text }
    let text: String
    var isSelected: Bool = false
}

class HomeViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var specialists: [Specialist] = []
    
    // Фильтры для специальностей, опыта и инструментов
    @Published var specialtyFilters: [FilterOption] = []
    @Published var experienceFilters: [FilterOption] = []
    @Published var toolFilters: [FilterOption] = []
    
    // Поиск
    @Published var specialtySearchText = ""
    @Published var experienceSearchText = ""
    @Published var toolSearchText = ""
    
    init() {
        loadFilters()
    }
    
    func loadFilters() {
        // TODO: Сделать запоминание последних использованных фильтров в юзердефолтс
        specialtyFilters = [.init(text: "Саунд", isSelected: false), .init(text: "Фотография", isSelected: false), .init(text: "3D", isSelected: false), .init(text: "Дизайн", isSelected: false), .init(text: "Иллюстратор", isSelected: false), .init(text: "Бездельник", isSelected: false)]
        experienceFilters = [.init(text: "Нет опыта", isSelected: false), .init(text: "От 1 года до 3 лет", isSelected: false) , .init(text: "От 3 до 5 лет")]
        toolFilters = [.init(text: "Тест 1"), .init(text: "Тест 2"), .init(text: "Тест 3"), .init(text: "Тест 4"), .init(text: "Тест 5"),]
    }
    
    func fetchDataWithFilters() {
        projects = [
            Project(projectImage: URL(string: "https://example.com/projectImage1.png")!, projectName: "ZULI POSADA", roleRequired: "Графический дизайнер", requirement: "отрисовка логотипа по ТЗ", experience: "от 2 лет", tools: "Adobe Illustrator, Figma", authorAvatar: URL(string: "https://example.com/authorAvatar1.png")!, authorName: "Jane Kudrinskaia"),
            Project(projectImage: URL(string: "https://example.com/projectImage1.png")!, projectName: "ZULI POSADA", roleRequired: "Графический дизайнер", requirement: "отрисовка логотипа по ТЗ", experience: "от 2 лет", tools: "Adobe Illustrator, Figma", authorAvatar: URL(string: "https://example.com/authorAvatar1.png")!, authorName: "Jane Kudrinskaia"),
            Project(projectImage: URL(string: "https://example.com/projectImage1.png")!, projectName: "ZULI POSADA", roleRequired: "Графический дизайнер", requirement: "отрисовка логотипа по ТЗ", experience: "от 2 лет", tools: "Adobe Illustrator, Figma", authorAvatar: URL(string: "https://example.com/authorAvatar1.png")!, authorName: "Jane Kudrinskaia"),
            Project(projectImage: URL(string: "https://example.com/projectImage1.png")!, projectName: "ZULI POSADA", roleRequired: "Графический дизайнер", requirement: "отрисовка логотипа по ТЗ", experience: "от 2 лет", tools: "Adobe Illustrator, Figma", authorAvatar: URL(string: "https://example.com/authorAvatar1.png")!, authorName: "Jane Kudrinskaia"),
            // Добавьте другие тестовые проекты
        ]
        
        specialists = [
            Specialist(backgroundImage: URL(string: "https://example.com/backgroundImage1.png")!, specImage: URL(string: "https://example.com/specImage1.png")!, name: "Luis Moreno", profession: "Цифровой художник", experience: "2 года", tools: "Adobe Illustrator, Adobe Photoshop, Corel Painter, Procreate"),
            Specialist(backgroundImage: URL(string: "https://example.com/backgroundImage1.png")!, specImage: URL(string: "https://example.com/specImage1.png")!, name: "Luis Moreno", profession: "Цифровой художник", experience: "2 года", tools: "Adobe Illustrator, Adobe Photoshop, Corel Painter, Procreate"),
            Specialist(backgroundImage: URL(string: "https://example.com/backgroundImage1.png")!, specImage: URL(string: "https://example.com/specImage1.png")!, name: "Luis Moreno", profession: "Цифровой художник", experience: "2 года", tools: "Adobe Illustrator, Adobe Photoshop, Corel Painter, Procreate"),
            // Добавьте другие тестовые специалисты
        ]
        print("Fetching data with current filters...")
    }
    
    // Функции для обновления выбранного состояния
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
    
    // Функции для сортировки выбранных фильтров
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
        specialtyFilters.contains(where: { $0.isSelected }) ||
        experienceFilters.contains(where: { $0.isSelected }) ||
        toolFilters.contains(where: { $0.isSelected })
    }
    
    func resetFilters() {
        specialtyFilters = specialtyFilters.map { FilterOption(text: $0.text, isSelected: false) }
        experienceFilters = experienceFilters.map { FilterOption(text: $0.text, isSelected: false) }
        toolFilters = toolFilters.map { FilterOption(text: $0.text, isSelected: false) }
    }
}
