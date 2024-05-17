//
//  LoginViewModel.swift
//  Collart
//
//  Created by Nik Y on 08.01.2024.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var password: String = ""
    
    @Published var isValidLogin: Bool = false
    @Published var isValidPassword: Bool = false
    
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var showAlert = false
    @Published var allertMessage = ""
    @Published var hasError = false
    
    var canProceed: Bool {
        return isValidLogin && isValidPassword
    }
    
    // Функция для попытки входа
    func attemptLogin() {
        tryLogin()
    }
    
    private func tryLogin() {
        print(password)
//        guard let password = UserManager.hashPassword(password) else {
//            return
//        }
//        print(password)
        isLoading = true
        NetworkService.loginUser(email: login, password: password) { success, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            if (error != nil) {
                print(error?.localizedDescription)
            }
        }
    }
}
