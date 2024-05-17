//
//  CreatePortfolioView.swift
//  Collart
//
//  Created by Nik Y on 14.05.2024.
//

import SwiftUI

struct CreatePortfolioView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = CreatePortfolioViewModel()
    @State var isLoading = false
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    TextErrorField(
                        placeHolder: "Название проекта",
                        fieldText: $viewModel.name,
                        isValid: $viewModel.isValidName,
                        validateMethod: Validator.validateName,
                        errorText: "Введите название проекта"
                    )
                    .padding(.bottom, 3)
                    
                    TextErrorEditor(
                        placeHolder: "Описание проекта",
                        fieldText: $viewModel.description,
                        isValid: $viewModel.isValidDesc
                    )
                    .padding(.bottom, 3)
                    
                    HStack {
                        ImagePickerField(image: $viewModel.image)
                        Spacer()
                    }
                    
                    HStack {
                        FilePickerField(fileUrls: $viewModel.fileUrls)
                        Spacer()
                    }
                }
                .padding()
                .padding(.top, 10)
            }
            Spacer()
            
            Button {
                isLoading = true
                viewModel.submitPortfolio {
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Опубликовать")
                }
            }
            .buttonStyle(ConditionalButtonStyle(conditional: viewModel.canProceed))
            .disabled(!viewModel.canProceed)
            .animation(.easeInOut, value: viewModel.canProceed)
            .padding()
            .padding(.bottom, 6)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                        }.foregroundColor(settings.currentTheme.textColorPrimary)
                    }
                    Spacer()
                    Text("Создать портфолио")
                        .font(.system(size: settings.textSizeSettings.pageName))
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                }
            }
        }
    }
}

import Foundation
import UIKit

class CreatePortfolioViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var image: UIImage? = nil
    @Published var fileUrls: [URL] = []
    
    @Published var isValidName: Bool = false
    @Published var isValidDesc: Bool = false
    
    @Published var isLoading = false
    
    func submitPortfolio(completion: @escaping () -> ()) {
        let portfolioDetails = PortfolioProjectParameters(
            name: name,
            description: description
        )

        let portfolioForm = PortfolioProjectForm(
            parameters: portfolioDetails,
            image: image,
            files: fileUrls.reduce(into: [String: URL]()) { result, url in result["file\(result.count + 1)"] = url }
        )

        NetworkService.addPortfolio(portfolioForm: portfolioForm) { success, error in
            if success {
                print("Portfolio added successfully.")
            } else if let error = error {
                print("Error adding portfolio: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    var canProceed: Bool {
        return isValidName && isValidDesc
    }
}

