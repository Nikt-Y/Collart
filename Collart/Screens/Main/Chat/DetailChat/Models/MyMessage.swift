//
//  MyMessage.swift
//  Collart
//

import Foundation

// MARK: - Message Model
struct Message: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var text: String
    var isSender: Bool
    var readStatus: Bool
    var timestamp: Date
}

// MARK: - MessageSection Model
struct MessageSection: Identifiable {
    var id: Date { date }
    var date: Date
    var messages: [Message]
}

