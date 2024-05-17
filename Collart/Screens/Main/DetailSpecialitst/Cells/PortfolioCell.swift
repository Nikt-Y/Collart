//
//  PortfolioCell.swift
//  Collart
//
//  Created by Nik Y on 26.03.2024.
//

import SwiftUI
import CachedAsyncImage

struct PortfolioCell: View {
    @EnvironmentObject var settingsManager: SettingsManager

    var imageName: String
    var title: String

    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: !imageName.isEmpty ? imageName : "no url"), urlCache: .imageCache) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .empty:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                        .scaledToFill()
                case .failure(_):
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                @unknown default:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                        .scaledToFill()
                }
            }
                .frame(height: 100)
                .clipped()
                .foregroundColor(.black)
                .clipped()

            Text(title)
                .font(.system(size: settingsManager.textSizeSettings.body))
                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                .multilineTextAlignment(.leading)
                .bold()
                .padding(.bottom, 8)
                .padding(.horizontal, 3)
                .lineLimit(3)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(settingsManager.currentTheme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}

#Preview {
    PortfolioCell(imageName: "", title: "Feel Good Co.")
        .environmentObject(SettingsManager())
}
