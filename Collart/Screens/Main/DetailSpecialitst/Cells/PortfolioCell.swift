//
//  PortfolioCell.swift
//  Collart
//

import SwiftUI
import CachedAsyncImage

struct PortfolioCell: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State var isShowingDetailProject = false

    var project: PortfolioProject

    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: !project.projectImage.isEmpty ? project.projectImage : "no url"), urlCache: .imageCache) { phase in
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
                .clipped()
                .contentShape(Rectangle())
            
            Text(project.projectName)
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
        .onTapGesture {
            isShowingDetailProject = true
        }
        .navigationDestination(isPresented: $isShowingDetailProject) {
            PortfolioView(project: project)
        }
    }
}
