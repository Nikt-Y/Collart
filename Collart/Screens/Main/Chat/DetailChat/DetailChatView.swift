//
//  DetailChatView.swift
//  Collart
//
//  Created by Nik Y on 22.04.2024.
//

import SwiftUI
import CachedAsyncImage

struct ChatView: View {
    @EnvironmentObject var settings: SettingsManager
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    
    var spec: Specialist
    @State private var messageText = ""
    
    init(spec: Specialist) {
        self.spec = spec
        _viewModel = ObservedObject(wrappedValue: ChatViewModel(senderID: UserManager.shared.user.id, receiverID: spec.id))
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Button(action: {
                    dismiss()
                    isBackFromChat = true
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                    }.foregroundColor(settings.currentTheme.textColorPrimary)
                }
                
                CachedAsyncImage(url: URL(string: !spec.specImage.isEmpty ? spec.specImage : "no url"), urlCache: .imageCache) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                    case .failure(_):
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                    @unknown default:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                    }
                }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                Text(spec.name)
                    .font(.system(size: settings.textSizeSettings.pageName))
                    .foregroundColor(settings.currentTheme.textColorPrimary)
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            ScrollView {
                ScrollViewReader { scrollView in
                    LazyVStack {
                        ForEach(viewModel.groupedMessages(), id: \.id) { section in
                            Section {
                                Text(section.date.formattedDate())
                                    .font(.system(size: settings.textSizeSettings.subTitle))
                                    .foregroundColor(settings.currentTheme.textColorOnPrimary)
                                    .padding(5)
                                    .background(settings.currentTheme.lightPrimaryColor)
                                    .clipShape(Capsule())
                                ForEach(section.messages) { message in
                                    MessageView(message: message)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .rotationEffect(.degrees(180)) // Переворачиваем VStack
                }
            }
            .rotationEffect(.degrees(180)) // Переворачиваем ScrollView
            
            messageInputArea
        }
        .onAppear {
            viewModel.markMessageAsRead()
        }
        .navigationBarBackButtonHidden()
    }
    
    var messageInputArea: some View {
        HStack {
            Button(action: attachFile) {
                Image(systemName: "paperclip").padding()
            }
            
            TextField("Write a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minHeight: CGFloat(30))
            
            Button("Send") {
                viewModel.sendMessage(messageText, isSender: true)
                messageText = ""
            }
            .padding()
        }
    }
    
    private func attachFile() {
        // Заглушка для функции прикрепления файла
    }
}

struct MessageView: View {
    @EnvironmentObject var settings: SettingsManager
    let message: Message
    
    var body: some View {
        HStack {
            if message.isSender {
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(message.text)
                        .foregroundColor(settings.currentTheme.textColorOnPrimary)
                        .font(.system(size: settings.textSizeSettings.semiPageName))
                        .padding(.bottom, 5)
                        .padding(.trailing, 4)
                        .padding(.top, 2)

                    HStack(spacing: 4) {
                        Text(message.timestamp.formattedTime())
                            .foregroundColor(settings.currentTheme.textColorOnPrimary)
                            .font(.system(size: settings.textSizeSettings.little))

                        if message.readStatus {
                            Image("done2")
                                .resizable()
                                .scaledToFit()
                                .frame(height: settings.textSizeSettings.little)
                                .foregroundColor(settings.currentTheme.textColorOnPrimary)
                        } else {
                            Image("done")
                                .resizable()
                                .scaledToFit()
                                .frame(height: settings.textSizeSettings.little)
                                .foregroundColor(settings.currentTheme.textColorOnPrimary)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(settings.currentTheme.primaryColor)
                .cornerRadius(15)

            } else {
                VStack(alignment: .trailing, spacing: 0) {
                    Text(message.text)
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                        .font(.system(size: settings.textSizeSettings.semiPageName))
                        .padding(.bottom, 5)
                        .padding(.trailing, 4)
                        .padding(.top, 2)

                    HStack(spacing: 4) {
                        Text(message.timestamp.formattedTime())
                            .foregroundColor(settings.currentTheme.textColorLightPrimary)
                            .font(.system(size: settings.textSizeSettings.little))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(settings.currentTheme.searchColor)
                .cornerRadius(15)

                Spacer()
            }
        }
    }
}

extension Date {
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}


//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView(spec: specialist1)
//            .environmentObject(SettingsManager())
//    }
//}
