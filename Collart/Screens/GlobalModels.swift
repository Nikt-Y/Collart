//
//  GlobalModels.swift
//  Collart
//

import Foundation

// MARK: Skill
struct Skill: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isSelected: Bool = false
    
    // Default skill values, just in case
    static var skills: [Skill] = [
        .init(text: "Программирование", isSelected: false),
        .init(text: "Саунд дизайнер", isSelected: false),
        .init(text: "Фотограф", isSelected: false),
        .init(text: "3D-дизайнер", isSelected: false),
        .init(text: "Иллюстратор", isSelected: false),
        .init(text: "CGI-артист", isSelected: false),
        .init(text: "Коммуникационный дизайнер", isSelected: false),
        .init(text: "Fashion дизайнер", isSelected: false),
        .init(text: "UX-дизайнер", isSelected: false),
        .init(text: "UI-дизайнер", isSelected: false),
        .init(text: "Motion-дизайнер", isSelected: false),
        .init(text: "Типограф", isSelected: false),
        .init(text: "Медиа дизайнер", isSelected: false),
        .init(text: "Копирайтер", isSelected: false),
        .init(text: "Маркетолог", isSelected: false),
        .init(text: "Арт-директор", isSelected: false),
        .init(text: "Unity-разработчик", isSelected: false),
        .init(text: "Full-stack разработчик", isSelected: false),
        .init(text: "Backend-разработчик", isSelected: false),
        .init(text: "iOS-разработчик", isSelected: false),
        .init(text: "Frontend-разработчик", isSelected: false)
    ]
}

// MARK: Experience
enum Experience: String {
    case noExperience = "no_experience"
    case years1_3 = "1-3_years"
    case years3_5 = "3-5_years"
    case yearsMore5 = "more_than_5_years"
    
    var text: String {
        switch self {
        case .noExperience:
            if LocalPersistence.shared.language == "ru" {
                return "Нет опыта"
            } else {
                return "No experience"
            }
        case .years1_3:
            if LocalPersistence.shared.language == "ru" {
                return "От 1 года до 3 лет"
            } else {
                return "1-3 years"
            }
        case .years3_5:
            if LocalPersistence.shared.language == "ru" {
                return "От 3 до 5 лет"
            } else {
                return "3-5 years"
            }
        case .yearsMore5:
            if LocalPersistence.shared.language == "ru" {
                return "Более 5 лет"
            } else {
                return "More than 5 years"
            }
        }
    }
    
    var value: Int {
        switch self {
        case .noExperience:
            return 0
        case .years1_3:
            return 1

        case .years3_5:
            return 2

        case .yearsMore5:
            return 3

        }
    }
    
    static func fromString(_ rawValue: String) -> Experience {
        return Experience(rawValue: rawValue) ?? Experience.noExperience
    }
}

struct Tool: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isSelected: Bool = false
    
    // Default tool values, just in case
    static var tools: [Tool] = [
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
}
