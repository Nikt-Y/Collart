//
//  ChatsListView.swift
//  Collart
//
//  Created by Nik Y on 17.03.2024.
//

import SwiftUI

struct ChatsListView: View {
    @StateObject var viewModel = ChatsListViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(content: {
                    ForEach(viewModel.chats, id: \.id) { chat in
                        NavigationLink {
                            ChatView(spec: chat.user)
                        } label: {
                            ChatListCellView(spec: chat.user, lastMessage: chat.lastMessage, status: chat.status, time: chat.timeLast, numOfUnread: chat.numOfUnread)
                        }
                    }
                })
            }
        }
        .onAppear {
            viewModel.fetchChats()
        }
    }
}


struct ChatsListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsListView()
            .environmentObject(SettingsManager())
    }
}
