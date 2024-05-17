//
//  LocalPersistance.swift
//  Collart
//
//  Created by Nik Y on 08.05.2024.
//

import Foundation

// MARK: - UserDefaults Keys
fileprivate let kUserID = "kUserID"
fileprivate let kToken = "kToken"
fileprivate let kLanguage = "kLanguage"

final class LocalPersistence {
    static var shared: LocalPersistence = {
        let instance = LocalPersistence()
        if instance.language == nil {
            instance.language = "ru"
        }
        return instance
    }()
    
    var userID: String? {
        set (newVal) {
            UserDefaults.standard.set(newVal, forKey: kUserID)
        }
        get {
            UserDefaults.standard.string(forKey: kUserID)
        }
    }
    
    var token: String? {
        set (newVal) {
            UserDefaults.standard.set(newVal, forKey: kToken)
        }
        get {
            UserDefaults.standard.string(forKey: kToken)
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
}
