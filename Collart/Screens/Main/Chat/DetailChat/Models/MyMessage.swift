//
//  MyMessage.swift
//  Collart
//
//  Created by Nik Y on 22.04.2024.
//

import Foundation

struct Message: Identifiable, Equatable {
    var id: String = UUID().uuidString
    var text: String
    var isSender: Bool
    var readStatus: Bool
    var timestamp: Date
}

struct MessageSection: Identifiable {
    var id: Date { date }
    var date: Date
    var messages: [Message]
}

