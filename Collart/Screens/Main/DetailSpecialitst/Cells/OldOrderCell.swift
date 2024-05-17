//
//  OldOrderCell.swift
//  Collart
//
//  Created by Nik Y on 26.03.2024.
//

import SwiftUI
import CachedAsyncImage

struct OldOrderCell: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State var isShowingDetailProject = false
    
    var oldOrder: OldProject
    
    private var authorsNames: String {
        oldOrder.contributors.map { $0.name }.joined(separator: " & ")
    }
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: !oldOrder.project.projectImage.isEmpty ? oldOrder.project.projectImage : "no url"), urlCache: .imageCache) { phase in
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
                .frame(height: 150)
                .clipped()
                .foregroundColor(.black)
                .clipped()
                .contentShape(Rectangle())
            
            HStack {
                ZStack {
                    ForEach(0..<oldOrder.contributors.count, id: \.self) { index in
                        CachedAsyncImage(url: URL(string: !oldOrder.contributors[index].specImage.isEmpty ? oldOrder.contributors[index].specImage : "no url"), urlCache: .imageCache) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                            case .failure(_):
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                            @unknown default:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                            }
                        }
                            .background(settingsManager.currentTheme.backgroundColor)
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(settingsManager.currentTheme.backgroundColor, lineWidth: 2))
                            .offset(x: CGFloat(index * 19), y: 0)
                            .zIndex(Double(oldOrder.contributors.count - index))
                    }
                }
                .padding(.horizontal, 10)
                
                
                VStack(alignment: .leading) {
                    Text(authorsNames)
                        .font(.system(size: settingsManager.textSizeSettings.subTitle))
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                        .padding(.vertical, 4)
                    
                    Text(oldOrder.project.projectName)
                        .font(.system(size: settingsManager.textSizeSettings.title))
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                        .bold()
                        .padding(.bottom, 8)
                }
                .padding(.horizontal)
                
                Spacer()

            }
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            isShowingDetailProject = true
        }
        .shadow(radius: 5)
        .padding(.bottom, 2)
        .navigationDestination(isPresented: $isShowingDetailProject) {
            DetailProjectView(project: oldOrder.project)
        }
    }
}

//#Preview {
//    OldOrderCell(oldOrder: OldProject(contributors: [specialist1, specialist2], project: project1))
//    .environmentObject(SettingsManager())
//}
