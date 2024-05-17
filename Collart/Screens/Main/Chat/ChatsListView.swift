//
//  ChatsListView.swift
//  Collart
//
//  Created by Nik Y on 17.03.2024.
//

import SwiftUI

struct ChatsListView: View {
    @EnvironmentObject var settings: SettingsManager
    @StateObject var viewModel = ChatsListViewModel()
    @State var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                        .scaleEffect(3)
                } else {
                    ScrollView {
                        LazyVStack(content: {
                            ForEach(viewModel.chats, id: \.id) { chat in
                                NavigationLink {
                                    ChatView(specId: chat.user.id, specImage: chat.user.specImage, specName: chat.user.name)
                                } label: {
                                    ChatListCellView(spec: chat.user, lastMessage: chat.lastMessage, status: chat.status, time: chat.timeLast, numOfUnread: chat.numOfUnread)
                                }
                            }
                        })
                        .overlay {
                            if viewModel.chats.isEmpty {
                                Text("У Вас нет активных чатов")
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchChats {_ in 
                isLoading = false
            }
        }
    }
}


struct ChatsListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsListView()
            .environmentObject(SettingsManager())
    }
}
