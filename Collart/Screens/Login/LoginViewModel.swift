//
//  LoginViewModel.swift
//  Collart
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var login: String = ""
    @Published var password: String = ""
    
    @Published var isValidLogin: Bool = false
    @Published var isValidPassword: Bool = false
    
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var showAlert = false
    @Published var allertMessage = ""
    @Published var hasError = false
    
    private var authenticationService: AuthenticationServiceDelegate {
        networkService
    }
    
    var canProceed: Bool {
        return isValidLogin && isValidPassword
    }
    
    func attemptLogin() {
        tryLogin()
    }
    
    private func tryLogin() {
        print(password)
//        guard let password = UserManager.hashPassword(password) else {
//            return
//        }
        isLoading = true
        authenticationService.loginUser(email: login, password: password) { success, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            if (error != nil) {
                print(error?.localizedDescription)
            }
        }
    }
}
