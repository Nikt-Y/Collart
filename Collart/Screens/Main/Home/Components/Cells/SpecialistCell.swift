//
//  SpecialistCell.swift
//  Collart
//
//  Created by Nik Y on 17.02.2024.
//

import SwiftUI
import CachedAsyncImage

// TODO: Может стоит добавить описание к специалисту?
struct SpecialistCell: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State var isNotSelected: Bool = true
    var specialist: Specialist
    var onRespond: () -> Void = {}
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: !specialist.backgroundImage.isEmpty ? specialist.backgroundImage : "no url"), urlCache: .imageCache) { phase in
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
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                .overlay(alignment: .bottom) {
                    CachedAsyncImage(url: URL(string: !specialist.specImage.isEmpty ? specialist.specImage : "no url"), urlCache: .imageCache) { phase in
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
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .padding(5)
                    .background(settingsManager.currentTheme.backgroundColor)
                    .clipShape(Circle())
                    .offset(y: 10)
                }
            
            VStack(spacing: 5) {
                Text(specialist.name)
                    .font(.system(size: settingsManager.textSizeSettings.pageName))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .bold()
                    .padding(.bottom, 1)
                
                Text(specialist.profession)
                    .font(.system(size: settingsManager.textSizeSettings.title))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    
                if !specialist.subProfession.isEmpty {
                    Text(specialist.subProfession)
                        .multilineTextAlignment(.center)
                        .font(.system(size: settingsManager.textSizeSettings.title))
                        .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                        .padding(.horizontal)
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Group {
                            Text("Опыт работы: \(specialist.experience)")
                                .font(.system(size: settingsManager.textSizeSettings.body))
                                .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                            
                            Text("Программы: \(specialist.tools)")
                                .font(.system(size: settingsManager.textSizeSettings.body))
                                .foregroundColor(settingsManager.currentTheme.textDescriptionColor)
                        }
                        .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(.top, 3)
                .padding(.horizontal)

                
                Button(isNotSelected ? "Пригласить" : "Приглашение отправлено") {
                    onRespond()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        isNotSelected.toggle()
//                    }
                }
                .buttonStyle(ConditionalButtonStyle(conditional: isNotSelected))
                .padding()
            }
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.bottom, 2)
    }
}
//
//struct SpecialistCell_Previews: PreviewProvider {
//    static var previews: some View {
//        SpecialistCell()
//            .environmentObject(SettingsManager())
//    }
//}
