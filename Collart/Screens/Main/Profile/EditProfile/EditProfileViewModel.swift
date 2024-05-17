import Foundation
import SwiftUI

class EditProfileViewModel: ObservableObject {
    @Published var name: String
    @Published var surname: String
    @Published var email: String
    @Published var skills: [Skill]
    @Published var tools: [Tool]
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
    
    init(user: User) {
        self.name = user.name
        self.surname = user.surname
        self.email = user.email
        self.skills = Skill.skills.map { skill in
            var newSkill = skill
            newSkill.isSelected = user.profession == skill.text || user.subProfessions.contains(skill.text)
            return newSkill
        }
        self.tools = Tool.tools.map { tool in
            var newTool = tool
            newTool.isSelected = user.tools.contains(tool.text)
            return newTool
        }
        self.experience = Experience.fromString(user.experience)
        self.profession = user.profession
        self.subProfessions = user.subProfessions
        self.searchable = user.searchable
    }
    
    var canProceed: Bool {
        return isValidName && isValidEmail
    }
    
    func saveChanges(completion: @escaping (Bool, Error?) -> Void) {
        let selectedSkills = skills.filter { $0.isSelected }.map { $0.text }
        let selectedTools = tools.filter { $0.isSelected }.map { $0.text }
        
        isLoading = true
        
        NetworkService.updateUserProfile(
            email: email,
            name: name,
            surname: surname,
            searchable: searchable ? "true" : "false",
            experience: experience.rawValue,
            passwordHash: password.isEmpty ? nil : hashPassword(password),
            confirmPasswordHash: password.isEmpty ? nil : hashPassword(password),
            description: nil,
            skills: selectedSkills,
            tools: selectedTools,
            image: image,
            cover: cover,
            completion: { success, error in
                self.isLoading = false
                completion(success, error)
            }
        )
    }
    
    private func hashPassword(_ password: String) -> String {
        // Хеширование пароля
        return password // Здесь должен быть ваш алгоритм хеширования
    }
}
