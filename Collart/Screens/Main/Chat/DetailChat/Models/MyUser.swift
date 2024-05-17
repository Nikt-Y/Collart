////
////  MyUser.swift
////  Collart
////
////  Created by Nik Y on 22.04.2024.
////
//
//import Foundation
//import ExyteChat
//
//struct MyUser: Equatable {
//    let uid: String
//    let name: String
//    let avatar: URL?
//
//    init(uid: String, name: String, avatar: URL? = nil) {
//        self.uid = uid
//        self.name = name
//        self.avatar = avatar
//    }
//}
//
//extension MyUser {
//    var isCurrentUser: Bool {
//        uid == "1"
//    }
//}
//
//extension MyUser {
//    func toChatUser() -> ExyteChat.User {
//        ExyteChat.User(id: uid, name: name, avatarURL: avatar, isCurrentUser: isCurrentUser)
//    }
//}
