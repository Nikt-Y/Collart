//
//  RegistrationViewModel.swift
//  Collart
//
//  Created by Nik Y on 24.01.2024.
//

import Foundation

class RegistrationViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var login: String = ""
    @Published var mail: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var skills: [String] = [""]

    @Published var isValidName: Bool = false
    @Published var isValidLogin: Bool = false
    @Published var isValidMail: Bool = false
    @Published var isValidPassword: Bool = false
    @Published var isValidConfirmPassword: Bool = false
    @Published var isSelectedActivity: Bool = false

    @Published var searchText: String = ""

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

    @Published var isLoading = false

    var canProceed: Bool {
        return isValidName && isValidLogin && isValidMail && isValidPassword && isValidConfirmPassword && isSelectedActivity
    }

    func attemptLogin() {
        sendRegisterUser()
    }

    func validateConfirm(_ confirmPassword: String) -> Bool {
        return password == confirmPassword
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

    private func sendRegisterUser() {
        guard let password = UserManager.hashPassword(password) else {
            return
        }
        isLoading = true
        NetworkService.registerUser(
            email: mail,
            password: password,
            confirmPassword: password,
            name: name,
            surname: "",
            description: "",
            userPhoto: "",
            cover: "",
            searchable: true,
            experience: "no_experience",
            skills: skills.compactMap({ $0.isEmpty ? nil : $0 }),
            tools: []) { success, error in
                if success {
                    NetworkService.loginUser(email: self.mail, password: password) { success, error in
                        if !success {
                            print("login error")
                        }
                        self.isLoading = false
                    }
                } else {
                    self.isLoading = false
                    print("register error")
                }
            }
    }
}
