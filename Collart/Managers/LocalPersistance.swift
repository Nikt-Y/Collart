//
//  LocalPersistance.swift
//  Collart
//

import Foundation
import Security

// MARK: - Keys
fileprivate let kUserID = "kUserID"
fileprivate let kLanguage = "kLanguage"
fileprivate let kSalt = "salt"
fileprivate let kTokenKeychainKey = "kTokenKeychainKey"

// MARK: - LocalPersistence
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
            if let token = newVal {
                saveToken(token: token, forKey: kTokenKeychainKey)
            } else {
                deleteToken(forKey: kTokenKeychainKey)
            }
        }
        get {
            return retrieveToken(forKey: kTokenKeychainKey)
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
    
    var salt: String? {
        get {
            UserDefaults.standard.string(forKey: kSalt)
        }
    }
    
    // MARK: - Keychain Helpers
    
    private func saveToken(token: String, forKey key: String) {
        if let data = token.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    private func retrieveToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data, let token = String(data: data, encoding: .utf8) {
            return token
        }
        return nil
    }
    
    private func deleteToken(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
