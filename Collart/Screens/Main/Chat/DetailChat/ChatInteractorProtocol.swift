//
//  ChatInteractorProtocol.swift
//  Collart
//
//  Created by Nik Y on 22.04.2024.
//
//
//import Foundation
//import Combine
//import ExyteChat
//
//protocol ChatInteractorProtocol {
//    var messages: AnyPublisher<[MyMessage], Never> { get }
//    var senders: [MyUser] { get }
//    var otherSenders: [MyUser] { get }
//
//    func send(draftMessage: ExyteChat.DraftMessage)
//
//    func connect()
//    func disconnect()
//
//    func loadNextPage() -> Future<Bool, Never>
//}
