//
//  NetworkService.swift
//  Collart
//
//  Created by Nik Y on 28.12.2023.
//

//NetworkService.fetchSkills { [weak self] result in
//            switch result {
//            case .success(let skills):
//                self?.updateUI(with: skills)
//            case .failure(let error):
//                self?.handleError(error)
//            }
//        }

import Foundation
import UIKit

class NetworkService {
    static func fetchSkills(completion: @escaping (Result<[Skill], Error>) -> Void) {
        print("skill fetch start")
        guard let url = URL(string: "https://collart-api.onrender.com/skills") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }
            
            if httpResponse.statusCode != 200 {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server responded with an error"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let skillsData = try JSONDecoder().decode([SkillData].self, from: data)
                let skills = transformToSkills(from: skillsData)
                DispatchQueue.main.async {
                    completion(.success(skills))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private static func transformToSkills(from data: [SkillData]) -> [Skill] {
        let language = UserDefaults.standard.string(forKey: "language") ?? "ru"
        return data.map { skillData in
            let text = language == "ru" ? skillData.nameRu : skillData.nameEn
            return Skill(text: text)
        }
    }
    
    static func registerUser(email: String, password: String, confirmPassword: String, name: String, surname: String, description: String, userPhoto: String, cover: String, searchable: Bool, experience: String, skills: [String], tools: [String], completion: @escaping (Bool, Error?) -> Void) {
        let url = URL(string: "https://collart-api.onrender.com/authentication/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "passwordHash": password,
            "confirmPasswordHash": confirmPassword,
            "name": name,
            "surname": surname,
            "description": description,
            "userPhoto": userPhoto,
            "cover": cover,
            "searchable": searchable,
            "experience": experience,
            "skills": skills,
            "tools": tools
        ]
        
        do {
            let test = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(false, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
        
        task.resume()
    }
    
    static func loginUser(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let url = URL(string: "https://collart-api.onrender.com/authentication/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "email": email,
            "password": password
        ]
        print("loginUser: " + email + " " + password)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(false, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                completion(false, NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Login failed"]))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let token = json["token"] as? String {
                    print("login success")
                    DispatchQueue.main.async {
                        UserManager.shared.setToken(newToken: token)
                    }
                    completion(true, nil)
                } else {
                    completion(false, NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Token not found"]))
                }
            } catch {
                completion(false, error)
            }
        }
        
        task.resume()
    }
    
    // MARK: Home Tab
    static func fetchListOfOrders(completion: @escaping (Result<[NWOrder], Error>) -> Void) {
        guard let url = URL(string: "https://collart-api.onrender.com/search/orders/all") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserManager.shared.token else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch orders"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let orders = try JSONDecoder().decode([NWOrder].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(orders))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    static func fetchListOfUsers(completion: @escaping (Result<[NWUserDetails], Error>) -> Void) {
        guard let url = URL(string: "https://collart-api.onrender.com/search/users/all") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserManager.shared.token else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch users"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let users = try JSONDecoder().decode([NWUserDetails].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(users))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: Interactions Tab
    class Interactions {
        
        static func responce(orderID: String, ownerId: String, completion: @escaping (Bool, Error?) -> Void) {
            guard let url = URL(string: "https://collart-api.onrender.com/interactions") else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let token = UserManager.shared.token else {
                completion(false, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
                return
            }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let body: [String: Any] = [
                "senderID": UserManager.shared.user.id,
                "orderID": orderID,
                "getterID": ownerId
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(false, error)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(false, NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to send interaction"]))
                    return
                }
                
                completion(true, nil)
            }
            
            task.resume()
        }
        
        static func sendInvite(orderID: String, getterID: String, completion: @escaping (Bool, Error?) -> Void) {
            guard let url = URL(string: "https://collart-api.onrender.com/interactions") else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let token = UserManager.shared.token else {
                completion(false, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
                return
            }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let body: [String: Any] = [
                "senderID": UserManager.shared.user.id,
                "orderID": orderID,
                "getterID": getterID
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                completion(false, error)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(false, NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to send interaction"]))
                    return
                }
                
                completion(true, nil)
            }
            
            task.resume()
        }
        
        static func fetchUserInteractions(userId: String, completion: @escaping (Result<[Interaction], Error>) -> Void) {
            let urlString = "https://collart-api.onrender.com/interactions/user/\(userId)"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            guard let token = UserManager.shared.token else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
                return
            }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch interactions"])))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                do {
                    let interactionList = try JSONDecoder().decode([Interaction].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(interactionList))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
        static func acceptInteraction(interactionId: String, getterID: String, completion: @escaping (Bool, Error?) -> Void) {
            performInteraction(action: "accept", interactionId: interactionId, getterID: getterID, completion: completion)
        }
        
        static func rejectInteraction(interactionId: String, getterID: String, completion: @escaping (Bool, Error?) -> Void) {
            performInteraction(action: "reject", interactionId: interactionId, getterID: getterID, completion: completion)
        }
        
        private static func performInteraction(action: String, interactionId: String, getterID: String, completion: @escaping (Bool, Error?) -> Void) {
            let urlString = "https://collart-api.onrender.com/interactions/\(action)/\(interactionId)"
            guard let url = URL(string: urlString) else {
                completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let token = UserManager.shared.token else {
                completion(false, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
                return
            }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let body: [String: Any] = ["getterID": getterID]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = jsonData
            } catch {
                completion(false, error)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                completion(true, nil)
            }
            task.resume()
        }
    }
    
    // MARK: Chat
    class Chat {
        private static func createFormBody(parameters: [String: String], files: [String: URL]?, boundary: String) -> Data {
            var body = Data()
            
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
            
            if let files = files {
                for (key, fileUrl) in files {
                    guard let fileData = try? Data(contentsOf: fileUrl) else { continue }
                    let filename = fileUrl.lastPathComponent
                    body.append("--\(boundary)\r\n")
                    body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename)\"\r\n")
                    body.append("Content-Type: \(fileUrl.mimeType)\r\n\r\n")
                    body.append(fileData)
                    body.append("\r\n")
                }
            }
            
            body.append("--\(boundary)--\r\n")
            return body
        }
        
        private static func createRequest(urlString: String, parameters: [String: String], files: [String: URL]?, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            guard let url = URL(string: urlString) else {
                completion(nil, nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            guard let token = UserManager.shared.token else {
                completion(nil, nil, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
                return
            }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            request.httpBody = createFormBody(parameters: parameters, files: files, boundary: boundary)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
            task.resume()
        }
        
        
        static func sendMessage(senderID: String, receiverID: String, message: String, isRead: Bool, files: [URL]?, completion: @escaping (Bool, Error?) -> Void) {
            let urlString = "https://collart-api.onrender.com/messages/send"
            
            var parameters: [String: String] = [
                "senderID": senderID,
                "receiverID": receiverID,
                "message": message,
                "isRead": "\(isRead)"
            ]
            
            var filesDict: [String: URL] = [:]
            if let files = files {
                for (index, file) in files.enumerated() {
                    filesDict["files[\(index)]"] = file
                }
            }
            
            createRequest(urlString: urlString, parameters: parameters, files: filesDict) { data, response, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(false, NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to send message"]))
                    return
                }
                completion(true, nil)
            }
        }
        
        static func fetchMessages(senderID: String, receiverID: String, offset: String?, limit: String?, completion: @escaping (Result<[Message], Error>) -> Void) {
            let urlString = "https://collart-api.onrender.com/messages/between"
            
            var parameters: [String: String] = [
                "senderID": senderID,
                "receiverID": receiverID
            ]
            
            if let offset = offset {
                parameters["offset"] = offset
            }
            
            if let limit = limit {
                parameters["limit"] = limit
            }
            
            createRequest(urlString: urlString, parameters: parameters, files: nil) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch messages"])))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let messages = try JSONDecoder().decode([Message].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(messages))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        
        static func markMessagesRead(senderID: String, receiverID: String, offset: String?, limit: String?, completion: @escaping (Bool, Error?) -> Void) {
            let urlString = "https://collart-api.onrender.com/messages/markRead"
            
            var parameters: [String: String] = [
                "senderID": senderID,
                "receiverID": receiverID
            ]
            
            if let offset = offset {
                parameters["offset"] = offset
            }
            
            if let limit = limit {
                parameters["limit"] = limit
            }
            
            createRequest(urlString: urlString, parameters: parameters, files: nil) { data, response, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(false, NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to mark messages as read"]))
                    return
                }
                completion(true, nil)
            }
        }
        
        static func fetchChats(userId: String, completion: @escaping (Result<[Chat], Error>) -> Void) {
            let urlString = "https://collart-api.onrender.com/messages/chats/\(userId)"
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            guard let token = UserManager.shared.token else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
                return
            }
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch chats"])))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                do {
                    let chats = try JSONDecoder().decode([Chat].self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(chats))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
        struct Message: Decodable {
            var files: [String]
            var isRead: Bool
            var message: String
            var updatedAt: String
            var sender: SimpleUser
            var receiver: SimpleUser
            var createdAt: String
            var id: String
        }
        
        struct Chat: Decodable {
            var lastMessage: String
            var userID: String
            var userName: String
            var userPhotoURL: String
            var unreadMessagesCount: Int
            var isRead: Bool
            var messageTime: String
        }
        
        struct SimpleUser: Decodable {
            var id: String
        }
        
        //        static func fetchChats() {
        //
        //        }
        //
        //        static func fetchChat(id: String) {
        //
        //        }
        //
        //        static func sendMessage(chatId: String) {
        //
        //        }
    }
    
    // MARK: Profile
    static func fetchUserProfile() {
        
    }
    
    
    static func fetchAuthenticatedUser(completion: @escaping (Result<AuthenticatedUserDetails, Error>) -> Void) {
        let urlString = "https://collart-api.onrender.com/authentication/user"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserManager.shared.token else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user details"])))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let userDetails = try JSONDecoder().decode(AuthenticatedUserDetails.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(userDetails))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    static func fetchUserOrders(userId: String, completion: @escaping (Result<[NWOrder], Error>) -> Void) {
        let urlString = "https://collart-api.onrender.com/tab/active/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserManager.shared.token else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch orders"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let orders = try JSONDecoder().decode([NWOrder].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(orders))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    
    static func fetchPortfolio(userId: String, completion: @escaping (Result<[PortfolioProject], Error>) -> Void) {
        let urlString = "https://collart-api.onrender.com/tab/portfolio/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserManager.shared.token else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch portfolio"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let portfolioList = try JSONDecoder().decode([PortfolioProject].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(portfolioList))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    static func fetchCompletedCollaborations(userId: String, completion: @escaping (Result<[NWOrder], Error>) -> Void) {
        let urlString = "https://collart-api.onrender.com/tab/collaborations/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserManager.shared.token else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch orders"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let orders = try JSONDecoder().decode([NWOrder].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(orders))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: Добавление проекта в избранное
    static func addOrderToFavorites(orderId: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "https://collart-api.onrender.com/orders/addOrderToFavorite/\(orderId)"
        guard let url = URL(string: urlString) else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = UserManager.shared.token else {
            completion(false, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
        task.resume()
    }
    
    // Метод для удаления проекта из избранного
    static func removeOrderFromFavorites(orderId: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "https://collart-api.onrender.com/orders/removeOrderFromFavorite/\(orderId)"
        guard let url = URL(string: urlString) else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = UserManager.shared.token else {
            completion(false, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
        task.resume()
    }
    
    // Метод для получения списка избранных проектов пользователя
    static func fetchFavorites(userId: String, completion: @escaping (Result<[NWOrder], Error>) -> Void) {
        let urlString = "https://collart-api.onrender.com/tab/favorites/\(userId)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        guard let token = UserManager.shared.token else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"])))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch favorites"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let favorites = try JSONDecoder().decode([NWOrder].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(favorites))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: Delete order
    static func deleteOrder(orderId: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "https://collart-api.onrender.com/orders/\(orderId)"
        guard let url = URL(string: urlString) else {
            completion(false, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let token = UserManager.shared.token else {
            completion(false, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
        task.resume()
    }
    
    // MARK: Add Order
    static func addOrder(orderForm: OrderForm, completion: @escaping (Bool, Error?) -> Void) {
        let url = URL(string: "https://collart-api.onrender.com/orders/addOrder")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let token = UserManager.shared.token else {
            completion(false, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = createBody(order: orderForm, boundary: boundary)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
        task.resume()
    }
    
    private static func createBody(order: OrderForm, boundary: String) -> Data {
        var body = Data()
        
        let mirror = Mirror(reflecting: order.parameters)
        for child in mirror.children {
            if let key = child.label, let value = child.value as? String {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for tool in order.parameters.tools {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"tools[]\"\r\n\r\n")
            body.append("\(tool)\r\n")
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"tools[]\"\r\n\r\n")
            body.append("Postman\r\n")
        }
        
        if let image = order.image {
            if let imageData = image.jpegData(compressionQuality: 1) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            }
        }
        
        for (key, fileUrl) in order.files {
            if let fileData = try? Data(contentsOf: fileUrl) {
                let filename = fileUrl.lastPathComponent
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"\(filename)\"\r\n")
                body.append("Content-Type: \(fileUrl.mimeType)\r\n\r\n")
                body.append(fileData)
                body.append("\r\n")
            }
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    static func addPortfolio(portfolioForm: PortfolioProjectForm, completion: @escaping (Bool, Error?) -> Void) {
        let url = URL(string: "https://collart-api.onrender.com/projects/addPortfolio")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let token = UserManager.shared.token else {
            completion(false, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = createBodyPortfolio(portfolio: portfolioForm, boundary: boundary)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
        task.resume()
    }
    
    private static func createBodyPortfolio(portfolio: PortfolioProjectForm, boundary: String) -> Data {
        var body = Data()
        
        let mirror = Mirror(reflecting: portfolio.parameters)
        for child in mirror.children {
            if let key = child.label, let value = child.value as? String {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        if let image = portfolio.image {
            if let imageData = image.jpegData(compressionQuality: 1) {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            }
        }
        
        for (key, fileUrl) in portfolio.files {
            if let fileData = try? Data(contentsOf: fileUrl) {
                let filename = fileUrl.lastPathComponent
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"\(filename)\"\r\n")
                body.append("Content-Type: \(fileUrl.mimeType)\r\n\r\n")
                body.append(fileData)
                body.append("\r\n")
            }
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    // MARK: Редактирование профиля
    private static func createFormBody(parameters: [String: String], arrays: [String: [String]], images: [String: UIImage?], boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        for (key, array) in arrays {
            for value in array {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)[]\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for (key, image) in images {
            if let image = image {
                if let imageData = image.jpegData(compressionQuality: 1) {
                    body.append("--\(boundary)\r\n")
                    body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n")
                    body.append("Content-Type: image/jpeg\r\n\r\n")
                    body.append(imageData)
                    body.append("\r\n")
                }
            }
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }

    private static func createRequest(urlString: String, parameters: [String: String], arrays: [String: [String]], images: [String: UIImage?], method: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil, nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let token = UserManager.shared.token else {
            completion(nil, nil, NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Authentication token is not available"]))
            return
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = createFormBody(parameters: parameters, arrays: arrays, images: images, boundary: boundary)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
    }

    
    static func updateUserProfile(email: String?, name: String?, surname: String?, searchable: String?, experience: String?, passwordHash: String?, confirmPasswordHash: String?, description: String?, skills: [String]?, tools: [String]?, image: UIImage?, cover: UIImage?, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "https://collart-api.onrender.com/users/updateUser"
        
        var parameters: [String: String] = [:]
        
        if let email = email { parameters["email"] = email }
        if let name = name { parameters["name"] = name }
        if let surname = surname { parameters["surname"] = surname }
        if let searchable = searchable { parameters["searchable"] = searchable }
        if let experience = experience { parameters["experience"] = experience }
        if let passwordHash = passwordHash { parameters["passwordHash"] = passwordHash }
        if let confirmPasswordHash = confirmPasswordHash { parameters["confirmPasswordHash"] = confirmPasswordHash }
        if let description = description { parameters["description"] = description }
        
        var arrays: [String: [String]] = [:]
        
        if let skills = skills { arrays["skills"] = skills }
        if let tools = tools { arrays["tools"] = tools }
        
        createRequest(urlString: urlString, parameters: parameters, arrays: arrays, images: ["image": image, "cover": cover], method: "PUT") { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false, NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to update profile"]))
                return
            }
            completion(true, nil)
        }
    }
    
    // MARK: Models
    
    struct OrderList: Decodable {
        var orders: [NWOrder]
    }
    
    struct SkillData: Codable {
        var nameRu: String
        var nameEn: String
        var id: String?
        var primary: Bool?
    }
    
    // Обертка для списка пользователей
    struct NWUserList: Decodable {
        var users: [NWUserDetails]
    }
    
    // Детали пользователя включая навыки и инструменты
    
    
    struct Interaction: Decodable {
        var sender: NWUserDetails
        var id: String
        var status: String
        var getter: NWUserDetails
        var order: NWOrder
    }
    
    struct InteractionList: Decodable {
        var interactions: [Interaction]
    }
    
    struct AuthenticatedUserDetails: Decodable {
        var user: NWUser
        var tools: [String]
        var skills: [SkillData]  // Используем SkillData для навыков
    }
    
    struct PortfolioProject: Decodable {
        var id: String
        var description: String
        var user: NWUser
        var name: String
        var files: [String]
        var image: String
    }
}

struct NWUserDetails: Decodable {
    var user: NWUser
    var tools: [String]
    var skills: [NWSkill]
}

struct NWSkill: Decodable {
    var nameRu: String
    var nameEn: String
    var primary: Bool?
    var id: String?
}

struct NWUser: Decodable {
    var id: String
    var name: String?
    var searchable: Bool?
    var userPhoto: String?
    var experience: String?
    var email: String?
    var cover: String?
    var surname: String?
    var description: String?
}

struct NWOrder: Decodable {
    var user: NWUser
    var tools: [String]
    var skill: NWSkillInfo
    var order: NWOrderDetails
}

struct NWSkillInfo: Decodable {
    var nameEn: String
    var nameRu: String
}

struct NWOrderDetails: Decodable {
    var image: String
    var dataEnd: String
    var files: [String]
    var owner: NWUser
    var experience: String
    var dataStart: String
    var projectDescription: String
    var taskDescription: String
    var title: String
    var skill: String
    var isActive: Bool
    var id: String
}

struct OrderForm {
    var parameters: OrderForSend
    var image: UIImage?
    var files: [String: URL]
}

struct PortfolioProjectForm {
    var parameters: PortfolioProjectParameters
    var image: UIImage?
    var files: [String: URL]
}

struct PortfolioProjectParameters: Decodable {
    var name: String
    var description: String
}

struct OrderForSend: Decodable {
    var title: String
    var skill: String
    var taskDescription: String
    var projectDescription: String
    var experience: String
    var dataStart: String
    var dataEnd: String
    var tools: [String]
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

import UniformTypeIdentifiers

private extension URL {
    var mimeType: String {
        guard let utType = UTType(filenameExtension: self.pathExtension) else {
            return "application/octet-stream"
        }
        return utType.preferredMIMEType ?? "application/octet-stream"
    }
}
