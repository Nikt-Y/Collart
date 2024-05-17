//
//  Models.swift
//  Collart
//
//  Created by Nik Y on 09.03.2024.
//

import Foundation

struct Skill: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isSelected: Bool = false
    
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

struct ExperienceFilter: Identifiable, Equatable {
    let id = UUID()
    let experience: Experience
    var isSelected: Bool = false
    
    static var experiences: [ExperienceFilter] = [
        ExperienceFilter(experience: .noExperience),
        ExperienceFilter(experience: .years1_3),
        ExperienceFilter(experience: .years3_5),
        ExperienceFilter(experience: .yearsMore5),

    ]
}

struct Tool: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isSelected: Bool = false
    
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

//class Filters {
//    var shared = Filters()
//    
//    var skills: [SkillFilter]
//    var experiences: [Experience]
//    var tools: [Tool]
//    
//    init() {
//        skills = [.init(text: "Саунд", isSelected: false), .init(text: "Фотография", isSelected: false), .init(text: "3D", isSelected: false), .init(text: "Дизайн", isSelected: false), .init(text: "Иллюстратор", isSelected: false), .init(text: "Бездельник", isSelected: false)]
//        experiences = [.init(text: "Нет опыта", value: 0, isSelected: false), .init(text: "От 1 года до 3 лет", value: 1, isSelected: false) , .init(text: "От 3 до 5 лет", value: 3)]
//        tools = [.init(text: "Тест 1"), .init(text: "Тест 2"), .init(text: "Тест 3"), .init(text: "Тест 4"), .init(text: "Тест 5"),]
//    }
//}

struct Order: Identifiable {
    var id: String
    var projectImage: String
    var projectName: String
    var roleRequired: String
    var requirement: String
    var experience: String
    var tools: String
    var authorAvatar: String
    var authorName: String
    var ownerID: String
    var description: String
    var files: [String] = []
    
    static func transformToOrder(from nwOrder: NWOrder) -> Order {
        Order(
            id: nwOrder.order.id,
            projectImage: nwOrder.order.image,
            projectName: nwOrder.order.title,
            roleRequired: nwOrder.skill.nameRu,
            requirement: nwOrder.order.taskDescription,
            experience: Experience.fromString(nwOrder.order.experience).text,
            tools: nwOrder.tools.joined(separator: ", "),
            authorAvatar: nwOrder.order.owner.userPhoto ?? "",
            authorName: "\(nwOrder.user.name!) \(nwOrder.user.surname!)".trimmingCharacters(in: [" "]),
            ownerID: nwOrder.order.owner.id,
            description: nwOrder.order.projectDescription)
    }
}

struct Specialist: Identifiable {
    let id: String
    let backgroundImage: String
    let specImage: String
    let name: String
    let profession: String
    let experience: String
    let tools: String
    let email: String
    let subProfession: String
    
    static func transformToSpecialist(from user: NWUserDetails) -> Specialist {
        let language = LocalPersistence.shared.language
        return Specialist(
            id: user.user.id,
            backgroundImage: user.user.cover ?? "",
            specImage: user.user.userPhoto ?? "",
            name: "\(user.user.name!) \(user.user.surname!)".trimmingCharacters(in: [" "]),
            profession: user.skills.compactMap(
                {
                    if $0.primary ?? false {
                        return language == "ru" ? $0.nameRu : $0.nameEn
                    } else {
                        return nil
                    }
                }).joined(separator: ", "),
            experience: Experience.fromString(user.user.experience ?? "").text,
            tools: user.tools.joined(separator: ", "),
            email: user.user.email ?? "",
            subProfession: user.skills.compactMap(
                {
                    if !($0.primary ?? false) {
                        return language == "ru" ? $0.nameRu : $0.nameEn
                    } else {
                        return nil
                    }
                }).joined(separator: ", ")
        )
    }
}

struct User: Identifiable {
    var id: String
    var backgroundImage: String // cover
    var avatar: String //
    var name: String
    var surname: String
    var profession: String // skill, который выбрали первым
    var email: String
    var subProfessions: [String] // Тоже skill, но который выбрали потом
    var tools: [String]
    var searchable: Bool // При отправке запроса отправляешь либо true, либо false
    var experience: String
    var portfolioProjects: [PortfolioProject] = []
    var oldProjects: [OldProject] = []
    var activeProjects: [Order] = []
    var liked: [Order] = []
}

struct OldProject: Identifiable {
    let id = UUID()
    let contributors: [Specialist]
    let project: Order
}

struct PortfolioProject: Identifiable {
    let id = UUID()
    let projectImage: String
    let projectName: String
    var description: String = ""
    let files: [String]
}

//let projectColl = Project(
//    projectImage: "proj6",
//    projectName: "Платформа для онлайн-обучения",
//    roleRequired: "Frontend-разработчик",
//    requirement: "Разработка веб-интерфейса для системы учета времени",
//    experience: "от 1 года до 3 лет",
//    tools: "Angular, Firebase, Figma",
//    authorAvatar: "kate_back",
//    authorName: "Ekaterina Akst",
//    description: "Цель проекта - создание удобного и функционального веб-интерфейса для системы учета рабочего времени сотрудников. Система позволит HR-специалистам и менеджерам отделов эффективно управлять рабочими часами, отпусками и больничными. Интерфейс предоставит графики и аналитику по времени работы, интеграцию с календарем для планирования отпусков, а также возможность создания отчетов для бухгалтерии. Разработка предполагает создание интуитивно понятного и простого в использовании интерфейса, который облегчит повседневные задачи учета времени и повысит общую продуктивность."
//)

// Creating an array of OldProject with a single element.

//============================================
//// This file was generated from JSON Schema using quicktype, do not modify it directly.
//// To parse the JSON, add this file to your project and do:
////
////   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)
//
//// MARK: - WelcomeElement
//struct WelcomeElement: Codable {
//    let skill: Skill
//    let order: Order
//    let tools: [String]
//    let user: User
//}
//
//// MARK: - Order
//struct Order: Codable {
//    let taskDescription: String
//    let isActive: Bool
//    let image: String
//    let experience: String
//    let dataStart: Date
//    let owner: User
//    let projectDescription, title: String
//    let files: [String]
//    let dataEnd: Date
//    let skill, id: String
//}
//
//// MARK: - User
//struct User: Codable {
//    let surname: String
//    let searchable: Bool
//    let name, userPhoto, id, cover: String
//    let experience, description, email: String
//}
//
//// MARK: - Skill
//struct Skill: Codable {
//    let nameEn, nameRu: String
//}
//
//typealias Welcome = [WelcomeElement]
