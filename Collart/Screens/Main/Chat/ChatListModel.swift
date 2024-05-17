//
//  ChatListModel.swift
//  Collart
//

import Foundation

// MARK: - MessageStatus
enum MessageStatus {
    case readed
    case unreaded
}

// MARK: - Chat
struct Chat {
    let id: UUID = UUID()
    let user: Specialist
    var lastMessage: String
    var numOfUnread: Int
    var status: MessageStatus
    var timeLast: Date
}
