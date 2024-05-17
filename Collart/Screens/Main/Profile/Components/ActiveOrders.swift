//
//  ActiveOrders.swift
//  Collart
//

import SwiftUI

struct ActiveOrders: View {
    @EnvironmentObject var settingsManager: SettingsManager

    var project: Order

    var body: some View {
        VStack(alignment: .leading) {
            Image(project.projectImage)
                .resizable()
                .scaledToFill()
                .clipped()
                .foregroundColor(.black)
                .frame(height: 160)
                .clipped()
            
            Group {
                Text("Ждет откликов")
                    .font(.system(size: settingsManager.textSizeSettings.body))
                    .foregroundColor(.green)
                    .bold()
                    .padding(.bottom, 8)


                Text(project.projectName)
                    .font(.system(size: settingsManager.textSizeSettings.body))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .bold()
                    .offset(y: -3)
                
                Text(project.roleRequired)
                    .font(.system(size: settingsManager.textSizeSettings.title))
                    .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    .bold()
                    .padding(.bottom, 10)
            }
            .padding(.horizontal)
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2)
    }
}

