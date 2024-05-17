//
//  ChatsListViewModel.swift
//  Collart
//
//  Created by Nik Y on 22.04.2024.
//

import Foundation

enum MessageStatus {
    case readed
    case unreaded
}

struct Chat {
    let id: UUID = UUID()
    let user: Specialist
    var lastMessage: String
    var numOfUnread: Int
    var status: MessageStatus
    var timeLast: Date
}

var isBackFromChat = false

class ChatsListViewModel: ObservableObject {
    @Published var chats: [Chat] = []

    func fetchChats() {
        let userId = UserManager.shared.user.id
        NetworkService.Chat.fetchChats(userId: userId) { [weak self] result in
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
                }
            case .failure(let error):
                print("Failed to fetch chats: \(error.localizedDescription)")
            }
        }
    }
}

