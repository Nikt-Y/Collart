//
//  Models.swift
//  Collart
//
//  Created by Nik Y on 09.03.2024.
//

import Foundation

struct Activity: Identifiable, Codable {
    let id: String
    let name: String
    
    static let activities: [Activity] = [.init(id: "1", name: "first"), .init(id: "2", name: "second"), .init(id: "3", name: "third")]
}

struct SkillFilter: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isSelected: Bool = false
}

struct Experience: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var value: Int
    var isSelected: Bool = false
}

struct Tool: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var isSelected: Bool = false
}

class Filters {
    var shared = Filters()
    
    var skills: [SkillFilter]
    var experiences: [Experience]
    var tools: [Tool]
    
    init() {
        skills = [.init(text: "Саунд", isSelected: false), .init(text: "Фотография", isSelected: false), .init(text: "3D", isSelected: false), .init(text: "Дизайн", isSelected: false), .init(text: "Иллюстратор", isSelected: false), .init(text: "Бездельник", isSelected: false)]
        experiences = [.init(text: "Нет опыта", value: 0, isSelected: false), .init(text: "От 1 года до 3 лет", value: 1, isSelected: false) , .init(text: "От 3 до 5 лет", value: 3)]
        tools = [.init(text: "Тест 1"), .init(text: "Тест 2"), .init(text: "Тест 3"), .init(text: "Тест 4"), .init(text: "Тест 5"),]
    }
}

struct Project: Identifiable {
    let id = UUID()
    let projectImage: URL
    let projectName: String
    let roleRequired: String
    let requirement: String
    let experience: String
    let tools: String
    let authorAvatar: URL
    let authorName: String
    var description: String = ""
}

struct Specialist: Identifiable {
    let id = UUID()
    let backgroundImage: URL
    let specImage: URL
    let name: String
    let profession: String
    let experience: String
    let tools: String
}

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
