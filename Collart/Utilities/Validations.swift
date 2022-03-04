//
//  Validations.swift
//  Collart
//
//  Created by Nik Y on 23.12.2023.
//

import Foundation

enum Validator {
    static func validateName(_ email: String) -> Bool {
        return true // TODO: 
    }
    
    static func validateLogin(_ email: String) -> Bool {
        return true // TODO: 
    }
    
    static func validateEmail(_ email: String) -> Bool {
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    static func validatePassword(_ password: String) -> Bool {
        return true
//        let passwordRegex = "^(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
//
//        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
//        return passwordPredicate.evaluate(with: password)
    }
}
