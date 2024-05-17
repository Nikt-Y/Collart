//
//  UserManager.swift
//  Collart
//
//  Created by Nik Y on 23.01.2024.
//

import Foundation
import SwiftUI

private struct UserManagerKey: EnvironmentKey {
    static var defaultValue: UserManager = UserManager()
}

extension EnvironmentValues {
    var userManager: UserManager {
        get { self[UserManagerKey.self] }
        set { self[UserManagerKey.self] = newValue }
    }
}

fileprivate let kUserID = "kUserID"
fileprivate let kToken = "kToken"
fileprivate let kLanguage = "kLanguage"

class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var user: User = User(id: "", backgroundImage: "", avatar: "", name: "", surname: "", profession: "", email: "", subProfessions: [], tools: [], searchable: false, experience: "")
    @Published var token: String?

    init() {
        token = LocalPersistence.shared.token
    }
    
    var userID: String? {
        set (newVal) {
            UserDefaults.standard.set(newVal, forKey: kUserID)
        }
        get {
            UserDefaults.standard.string(forKey: kUserID)
        }
    }
        
    var language: String? {
        set (newVal) {
            UserDefaults.standard.set(newVal, forKey: kLanguage)
        }
        get {
            UserDefaults.standard.string(forKey: kLanguage)
        }
    }

    func setToken(newToken: String?) {
        LocalPersistence.shared.token = newToken
        token = newToken
    }
    
    static func transformToUser(from details: NWUserDetails) -> User {
//        let name = "\(details.user.name ?? "") \(details.user.surname ?? "")".trimmingCharacters(in: [" "])
        let profession = details.skills.first(where: {$0.primary ?? false})?.nameRu ?? "Не указано"
        let subProfession = details.skills.compactMap({ skill in
            if !(skill.primary ?? true) {
                return skill.nameRu
            } else {
                return nil
            }
        })

        // Здесь пример заполнения данных, возможно, вам нужно будет извлечь эти данные из другого источника

        return User(
            id: details.user.id,
            backgroundImage: details.user.cover ?? "",
            avatar: details.user.userPhoto ?? "",
            name: details.user.name ?? "",
            surname: details.user.surname ?? "",
            profession: profession,
            email: details.user.email ?? "",
            subProfessions: subProfession,
            tools: details.tools,
            searchable: details.user.searchable ?? false,
            experience: details.user.experience ?? "no_experience",
            portfolioProjects: [],
            oldProjects: [], // Предположительно заполняется похожим образом
            activeProjects: [], // Нужна дополнительная логика для заполнения
            liked: [] // Нужна дополнительная логика для заполнения
        )
    }
}
