//
//  DetailProjectViewModel.swift
//  Collart
//
//  Created by Nik Y on 13.03.2024.
//

import Foundation

class DetailProjectViewModel: ObservableObject {
    var project: Order?

}

import Foundation
//
//struct Order: Codable {
//    let title: String
//    let dataEnd: Date
//    let skill: String
//    let dataStart: Date
//    let isActive: Bool
//    let image: String
//    let id: String
//    let owner: User
//    let files: [String]
//    let projectDescription, taskDescription, experience: String
//}

//// MARK: - WelcomeElement
//struct WelcomeElement: Codable {
//    let skill: Skill
//    let user: User
//    let order: Order
//    let tools: [String]
//}
//
//// MARK: - Order
//struct Order: Codable {
//    let title: String
//    let dataEnd: Date
//    let skill: String
//    let dataStart: Date
//    let isActive: Bool
//    let image: String
//    let id: String
//    let owner: User
//    let files: [String]
//    let projectDescription, taskDescription, experience: String
//}
//
//// MARK: - User
//struct User: Codable {
//    let userPhoto: String
//    let name: Name
//    let description: Description
//    let email: Email
//    let experience: Experience
//    let id: ID
//    let surname: Surname
//    let searchable: Bool
//    let cover: String
//}
//
//enum Description: String, Codable {
//    case aBriefDescriptionAboutJohnDoe = "A brief description about John Doe."
//    case empty = ""
//}
//
//enum Email: String, Codable {
//    case exampleMailRul = "example@mail.rul"
//    case user2ExampleCOM = "user2@example.com"
//}
//
//enum Experience: String, Codable {
//    case noExperience = "no_experience"
//}
//
//enum ID: String, Codable {
//    case e9C5E984Cba94B08892ECd8D0800A913 = "E9C5E984-CBA9-4B08-892E-CD8D0800A913"
//    case the675B650FF98E4A52A8A12Dfdc064289F = "675B650F-F98E-4A52-A8A1-2DFDC064289F"
//}
//
//enum Name: String, Codable {
//    case grisha = "grisha"
//    case john = "John"
//}
//
//enum Surname: String, Codable {
//    case doe = "Doe"
//    case pumpkin = "pumpkin"
//}
//
//// MARK: - Skill
//struct Skill: Codable {
//    let nameRu, nameEn: String
//}
//
//typealias Welcome = [WelcomeElement]
