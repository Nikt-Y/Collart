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
    @Published var activity: String = ""
    
    @Published var isValidName: Bool = false
    @Published var isValidLogin: Bool = false
    @Published var isValidMail: Bool = false
    @Published var isValidPassword: Bool = false
    @Published var isValidConfirmPassword: Bool = false
    @Published var isSelectedActivity: Bool = false
    
    @Published var searchText: String = ""

    var activityList: [Skill] {
        if searchText.isEmpty {
            return Skill.skills
        } else {
            return Skill.skills.filter{ $0.text.lowercased().contains(searchText.lowercased())}
        }
    }
    
    @Published var isLoading = false
        
    var canProceed: Bool {
        return isValidName && isValidLogin && isValidMail && isValidPassword && isValidConfirmPassword && isSelectedActivity
    }
    
    // Функция для попытки входа
    func attemptLogin() {
        sendRegisterUser()
        
    }
    
    func validateConfirm(_ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
    
    private func sendRegisterUser() {
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
            skills: [activity],
            tools: []) { success, error in
                if success {
                    NetworkService.loginUser(email: self.mail, password: self.password) { success, error in
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
