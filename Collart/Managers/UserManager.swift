//
//  UserManager.swift
//  Collart
//

import Foundation
import SwiftUI
import CommonCrypto

// MARK: - Creating Environment UserManager
private struct UserManagerKey: EnvironmentKey {
    static var defaultValue: UserManager = UserManager()
}

extension EnvironmentValues {
    var userManager: UserManager {
        get { self[UserManagerKey.self] }
        set { self[UserManagerKey.self] = newValue }
    }
}

// MARK: - User Keys
fileprivate let kUserID = "kUserID"
fileprivate let kToken = "kToken"
fileprivate let kLanguage = "kLanguage"

// MARK: - UserManager
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
    
    // MARK: Static fields
    static func transformToUser(from details: NetworkService.NWUserDetails) -> User {
        let profession = details.skills.first(where: {$0.primary ?? false})?.nameRu ?? "Не указано"
        let subProfession = details.skills.compactMap({ skill in
            if !(skill.primary ?? true) {
                return skill.nameRu
            } else {
                return nil
            }
        })

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
            oldProjects: [],
            activeProjects: [],
            liked: []
        )
    }
    
    static var salt: String {
        LocalPersistence.shared.salt ?? ""
    }
    
    static func hashPassword(_ password: String) -> String? {
        guard let data = (password + salt).data(using: .utf8) else { return nil }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
}
