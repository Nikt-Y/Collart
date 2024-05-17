//
//  ChatsListViewModel.swift
//  Collart
//

import SwiftUI

class ChatsListViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var chats: [Chat] = []

    private var chatService: ChatServiceDelegate {
        networkService
    }
    
    func fetchChats(completion: @escaping (Bool) -> ()) {
        let userId = UserManager.shared.user.id
        chatService.fetchChats(userId: userId) { [weak self] result in
            switch result {
            case .success(let chats):
                DispatchQueue.main.async {
                    self?.chats = chats.map { chat in
                        Chat(user: Specialist(id: chat.userID,
                                              backgroundImage: "",
                                              specImage: chat.userPhotoURL,
                                              name: chat.userName,
                                              profession: "",
                                              experience: "",
                                              tools: "",
                                              email: "",
                                              subProfession: ""),
                             lastMessage: chat.lastMessage,
                             numOfUnread: chat.unreadMessagesCount,
                             status: chat.isRead ? .readed : .unreaded,
                             timeLast: ISO8601DateFormatter().date(from: chat.messageTime) ?? Date())
                    }
                    completion(true)
                }
            case .failure(let error):
                print("Failed to fetch chats: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}

