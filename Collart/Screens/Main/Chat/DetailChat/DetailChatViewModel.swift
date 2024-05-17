//
//  DetailChatViewModel.swift
//  Collart
//

import Foundation
import SwiftUI

class DetailChatViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var messages = [Message]()
    
    var senderID: String
    var receiverID: String
    
    private var chatService: ChatServiceDelegate {
        networkService
    }
    
    init(senderID: String, receiverID: String) {
        self.senderID = senderID
        self.receiverID = receiverID
        loadMessages()
    }
    
    func loadMessages() {
        chatService.fetchMessages(senderID: senderID, receiverID: receiverID, offset: nil, limit: nil) { [weak self] result in
            switch result {
            case .success(let fetchedMessages):
                DispatchQueue.main.async {
                    self?.messages = fetchedMessages.map { message in
                        Message(id: message.id,
                                text: message.message,
                                isSender: message.sender.id == self?.senderID,
                                readStatus: message.isRead,
                                timestamp: ISO8601DateFormatter().date(from: message.createdAt) ?? Date())
                    }.sorted(by: { $0.timestamp < $1.timestamp }) // Сортировка по возрастанию даты
                }
            case .failure(let error):
                print("Failed to fetch messages: \(error.localizedDescription)")
            }
        }
    }
    
    func sendMessage(_ text: String, isSender: Bool) {
        let newMessage = Message(text: text, isSender: isSender, readStatus: false, timestamp: Date())
        
        chatService.sendMessage(senderID: senderID, receiverID: receiverID, message: text, isRead: false, files: nil) { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    self?.messages.append(newMessage)
                    self?.messages.sort(by: { $0.timestamp < $1.timestamp }) // Сортировка по возрастанию даты
                }
            } else {
                print("Failed to send message: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func markMessageAsRead() {
        chatService.markMessagesRead(senderID: receiverID , receiverID: senderID, offset: nil, limit: nil) { success, error in
            if success {
               
            } else {
                print("Failed to mark messages as read: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func groupedMessages() -> [MessageSection] {
        let grouped = Dictionary(grouping: messages) { message -> Date in
            let date = Calendar.current.startOfDay(for: message.timestamp)
            return date
        }
        return grouped.map { key, value in
            MessageSection(date: key, messages: value.sorted(by: { $0.timestamp < $1.timestamp }))
        }.sorted(by: { $0.date < $1.date }) // Сортировка по возрастанию даты
    }
}
