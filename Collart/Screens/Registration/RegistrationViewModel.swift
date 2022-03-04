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

    var activityList: [Activity] {
        if searchText.isEmpty {
            return Activity.activities
        } else {
            return Activity.activities.filter{ $0.name.lowercased().contains(searchText.lowercased())}
        }
    }
    
    @Published var isLoading = false
        
    var canProceed: Bool {
        return isValidName && isValidLogin && isValidMail && isValidPassword && isValidConfirmPassword && isSelectedActivity
    }
    
    // Функция для попытки входа
    func attemptLogin() {
        startFakeNetworkCall()
        
    }
    
    func validateConfirm(_ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
    
    private func startFakeNetworkCall() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            AuthenticationManager.shared.login()
        }
    }
}
