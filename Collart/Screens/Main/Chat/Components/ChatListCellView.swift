//
//  ChatListCellView.swift
//  Collart
//
//  Created by Nik Y on 22.04.2024.
//

import SwiftUI
import CachedAsyncImage

struct ChatListCellView: View {
    @EnvironmentObject private var settings: SettingsManager
    
    var spec: Specialist
    var lastMessage: String
    var status: MessageStatus
    var numOfUnread: Int
    var time: Date
    
    init(spec: Specialist, lastMessage: String, status: MessageStatus, time: Date, numOfUnread: Int = 0) {
        self.spec = spec
        self.lastMessage = lastMessage
        self.status = status
        self.numOfUnread = numOfUnread
        self.time = time
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
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
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(spec.name)
                            .font(.system(size: settings.textSizeSettings.title))
                            .foregroundColor(settings.currentTheme.textColorPrimary)
                            .bold()
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if numOfUnread > 0 {
                            Circle()
                                .fill(settings.currentTheme.primaryColor)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("\(numOfUnread)")
                                        .font(.system(size: settings.textSizeSettings.subTitle))
                                        .foregroundColor(settings.currentTheme.textColorOnPrimary)
                                )
                        } else {
                            if case .readed = status {
                                Image("done2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                                    .foregroundColor(settings.currentTheme.primaryColor)
                            } else {
                                Image("done")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 16)
                                    .foregroundColor(settings.currentTheme.primaryColor)
                            }
                        }
                    }
                    
                    Text(lastMessage)
                        .lineLimit(1)
                        .font(.system(size: settings.textSizeSettings.title))
                        .foregroundColor(settings.currentTheme.textColorLightPrimary)
                }
                .padding(.horizontal, 7)
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text(time.formattedTime())
                        .font(.system(size: settings.textSizeSettings.subTitle))
                        .foregroundColor(settings.currentTheme.textColorLightPrimary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal)
            
            Divider()
        }
        .background(settings.currentTheme.backgroundColor)
    }
}

//
//#Preview {
//    ChatListCellView(spec: specialist1, lastMessage: "Здарова", status: .unreaded, time: "11:11", numOfUnread: 0)
//        .environmentObject(SettingsManager())
//}
