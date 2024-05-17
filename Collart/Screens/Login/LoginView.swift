//
//  LoginView.swift
//  Collart
//
//  Created by Nik Y on 02.01.2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel = LoginViewModel()
    @FocusState private var focusedField: Field?
    @GestureState private var dragOffset = CGSize.zero
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    private enum Field {
        case username, password
    }
    
    var body: some View {
        ZStack {
            settingsManager.currentTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                TextErrorField(placeHolder: "Почта", fieldText: $viewModel.login, isValid: $viewModel.isValidLogin)
                    .padding(.bottom, 3)
                
                PasswordField(placeHolder: "Пароль", fieldText: $viewModel.password, isValid: $viewModel.isValidPassword)
                    .padding(.bottom, 3)
                
                HStack {
                    Spacer()
                    Button {
                        // TODO: Восстановление пароля
                    } label: {
                        Text("Забыли пароль?")
                            .foregroundColor(settingsManager.currentTheme.primaryColor)
                            .font(.system(size: settingsManager.textSizeSettings.body, weight: .semibold))
                    }
                }
                
                Button("Войти") {
                    viewModel.attemptLogin()
                    debugPrint("qwe")
                }
                .buttonStyle(ConditionalButtonStyle(conditional: viewModel.canProceed))
                .disabled(!viewModel.canProceed)
                .animation(.easeInOut, value: viewModel.canProceed)
                .padding(.bottom, 6)
                
                NavigationLink(destination: RegistrationView()) {
                    Text("Создайте новый аккаунт")
                        .foregroundColor(settingsManager.currentTheme.primaryColor)
                        .font(.system(size: settingsManager.textSizeSettings.semiPageName, weight: .semibold))
                }
                .padding(.bottom, 4)
                
                // TODO: Вход через это + мб вынести эту вью в отдельный файл
//                BottomView(googleAction: {}, facebookAction: {}, appleAction: {})
            }
            .padding(20)
            
            if viewModel.isLoading {
                ZStack {
                    settingsManager.currentTheme.backgroundColor
                        .opacity(0.6)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: settingsManager.currentTheme.primaryColor))
                        .scaleEffect(3)
                }
                .animation(.default, value: viewModel.isLoading)
            }
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
                        }.foregroundColor(settingsManager.currentTheme.textColorPrimary)
                    }
                    Spacer()
                    Text("Вход")
                        .font(.system(size: settingsManager.textSizeSettings.pageName))
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                }
            }
        }
        

    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .preferredColorScheme(.dark)
            .environmentObject(SettingsManager())
    }
}

struct BottomView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    var googleAction: () -> Void
    var facebookAction: () -> Void
    var appleAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Или продолжите через")
                .font(.system(size: settingsManager.textSizeSettings.body, weight: .semibold))
                .foregroundColor(settingsManager.currentTheme.textColorLightPrimary)
                .padding(.bottom, 5)
            
            HStack {
                Button {
                    googleAction()
                } label: {
                    Image("google-logo")
                        .resizable()
                }
                .buttonStyle(IconButtonStyle())
                
                Button {
                    facebookAction()
                } label: {
                    Image("facebook-logo")
                        .resizable()
                }
                .buttonStyle(IconButtonStyle())
                
                Button {
                    appleAction()
                } label: {
                    Image("apple-logo")
                        .resizable()
                }
                .buttonStyle(IconButtonStyle())
            }
        }
    }
}
