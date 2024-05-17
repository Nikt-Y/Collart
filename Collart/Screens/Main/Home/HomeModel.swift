//
//  HomeModel.swift
//  Collart
//

import Foundation

// MARK: - ExperienceFilter
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

// MARK: - Order
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
    
    static func transformToOrder(from nwOrder: NetworkService.NWOrder) -> Order {
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

// MARK: - Specialist
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
    
    static func transformToSpecialist(from user: NetworkService.NWUserDetails) -> Specialist {
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
