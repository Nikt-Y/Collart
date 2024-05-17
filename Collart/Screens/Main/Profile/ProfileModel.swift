//
//  ProfileModel.swift
//  Collart
//

import Foundation

// MARK: - User
struct User: Identifiable {
    var id: String
    var backgroundImage: String
    var avatar: String
    var name: String
    var surname: String
    var profession: String
    var email: String
    var subProfessions: [String]
    var tools: [String]
    var searchable: Bool
    var experience: String
    var portfolioProjects: [PortfolioProject] = []
    var oldProjects: [OldProject] = []
    var activeProjects: [Order] = []
    var liked: [Order] = []
}

// MARK: - OldProject
struct OldProject: Identifiable {
    let id = UUID()
    let contributors: [Specialist]
    let project: Order
}

// MARK: - PortfolioProject
struct PortfolioProject: Identifiable {
    let id: String
    let projectImage: String
    let projectName: String
    var description: String
    var ownerId: String
    let files: [String]
}
