//
//  InteractionsModel.swift
//  Collart
//

import Foundation

// MARK: - Response
struct Response {
    var id: String
    var responser: User
    var project: Order
    var status: InteractionStatus
}

// MARK: - Invite
struct Invite {
    var id: String
    var project: Order
    var status: InteractionStatus
}
