import Foundation
import SwiftUI

class EditProfileViewModel: ObservableObject {
    @Published var name: String
    @Published var surname: String
    @Published var email: String
    @Published var skills: [String]
    @Published var tools: [String]
    @Published var experience: Experience
    @Published var profession: String
    @Published var subProfessions: [String]
    @Published var searchable: Bool
    @Published var password: String = ""
    @Published var image: UIImage? = nil
    @Published var cover: UIImage? = nil
    
    @Published var isValidName: Bool = true
    @Published var isValidEmail: Bool = true
    
    @Published var showSkillSheet: Bool = false
    @Published var showToolSheet: Bool = false
    @Published var isLoading: Bool = false
    @Published var searchText = ""
    
    init(user: User) {
        self.name = user.name
        self.surname = user.surname
        self.email = user.email
        self.skills = [user.profession] + user.subProfessions
        self.tools = user.tools
        self.experience = Experience.fromString(user.experience)
        self.profession = user.profession
        self.subProfessions = user.subProfessions
        self.searchable = user.searchable
    }
    
    var canProceed: Bool {
        return isValidName && isValidEmail
    }
    
    var skillList: [Skill] {
        let filteredSkills = Skill.skills.filter { skill in
            !skills.contains(skill.text)
        }
        if searchText.isEmpty {
            return filteredSkills
        } else {
            return filteredSkills.filter { $0.text.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    func addSkill() {
        if skills.count < 3 {
            skills.append("")
        }
    }

    func removeSkill() {
        if skills.count > 1 {
            skills.removeLast()
        }
    }

    
    func saveChanges(completion: @escaping (Bool, Error?) -> Void) {
        isLoading = true
        
        NetworkService.updateUserProfile(
            email: email,
            name: name,
            surname: surname,
            searchable: searchable ? "true" : "false",
            experience: experience.rawValue,
            passwordHash: password.isEmpty ? nil : UserManager.hashPassword(password),
            confirmPasswordHash: password.isEmpty ? nil : UserManager.hashPassword(password),
            description: nil,
            skills: skills.filter({ !$0.isEmpty }),
            tools: tools,
            image: image,
            cover: cover,
            completion: { success, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(success, error)
                }
            }
        )
    }
}
