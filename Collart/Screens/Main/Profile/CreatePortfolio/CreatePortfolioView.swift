//
//  CreatePortfolioView.swift
//  Collart
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
