//
//  DetailChatView.swift
//  Collart
//

import SwiftUI
import CachedAsyncImage

// MARK: - ChatView
struct DetailChatView: View {
    @EnvironmentObject var settings: SettingsManager
    @ObservedObject var viewModel: DetailChatViewModel
    @Environment(\.dismiss) var dismiss
    
    var specId: String
    var specImage: String
    var specName: String
    @State private var messageText = ""
    
    init(specId: String, specImage: String, specName: String) {
        self.specId = specId
        self.specImage = specImage
        self.specName = specName
        _viewModel = ObservedObject(wrappedValue: DetailChatViewModel(senderID: UserManager.shared.user.id, receiverID: specId))
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Button(action: {
                    dismiss()
//                    isBackFromChat = true
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                    }.foregroundColor(settings.currentTheme.textColorPrimary)
                }
                
                CachedAsyncImage(url: URL(string: !specImage.isEmpty ? specImage : "no url"), urlCache: .imageCache) { phase in
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
                
                Text(specName)
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
                    .rotationEffect(.degrees(180))
                }
            }
            .rotationEffect(.degrees(180))
            
            messageInputArea
        }
        .onAppear {
            viewModel.markMessageAsRead()
        }
        .navigationBarBackButtonHidden()
    }
    
    var messageInputArea: some View {
        HStack {
            TextField("Сообщение", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(maxHeight: 50)
                .padding(.leading)
            
            Button {
                viewModel.sendMessage(messageText, isSender: true)
                messageText = ""
            } label: {
                Image("send")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(settings.currentTheme.primaryColor)
                    .tint(settings.currentTheme.primaryColor)
                    .frame(height: 30)
            }
            .padding()
        }
    }
}

// MARK: - MessageView
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
