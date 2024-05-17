//
//  RegistrationView.swift
//  Collart
//
//  Created by Nik Y on 02.01.2024.
//

import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @State private var presentActivitiesSheet: Bool = false
    
    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            settingsManager.currentTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                TextErrorField(
                    placeHolder: "Имя",
                    fieldText: $viewModel.name,
                    isValid: $viewModel.isValidName,
                    validateMethod: Validator.validateName,
                    errorText: "Введите имя и фамилию")
                .padding(.bottom, 3)
                
                TextErrorField(
                    placeHolder: "Фамилия",
                    fieldText: $viewModel.login,
                    isValid: $viewModel.isValidLogin,
                    validateMethod: Validator.validateLogin,
                    errorText: "Данный логин недоступен")
                .padding(.bottom, 3)
                
                TextErrorField(
                    placeHolder: "Почта",
                    fieldText: $viewModel.mail,
                    isValid: $viewModel.isValidMail,
                    validateMethod: Validator.validateEmail,
                    errorText: "Неверный формат почты"
                )
                .padding(.bottom, 3)
                
                PasswordField(
                    placeHolder: "Пароль",
                    fieldText: $viewModel.password,
                    isValid: $viewModel.isValidPassword,
                    validateMethod: Validator.validatePassword,
                    errorText: "Должен включать цифры и символы"
                )
                .padding(.bottom, 3)
                
                PasswordField(
                    placeHolder: "Повторите пароль",
                    fieldText: $viewModel.confirmPassword,
                    isValid: $viewModel.isValidConfirmPassword,
                    validateMethod: viewModel.validateConfirm,
                    errorText: "Пароли должны совпадать"
                )
                .padding(.bottom, 3)
                
                Button {
                    presentActivitiesSheet = true
                } label: {
                    HStack {
                        if viewModel.activity.isEmpty {
                            Text("Выберите специальность")
                        } else {
                            Text("\(viewModel.activity)")
                        }
                        
                        Spacer()
                        
                        Image("arrowDown")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: !viewModel.activity.isEmpty), lineWidth: 1))
                    .foregroundColor(settingsManager.currentTheme.selectedTextColor(isSelected: !viewModel.activity.isEmpty))
                    .font(.system(size: settingsManager.textSizeSettings.body))
                }
                .padding(.bottom, 3)
                
                HStack {
                    Button {
                        // TODO: Реализовать добавление специальности
                    } label: {
                        Text("Добавить специальность")
                            .foregroundColor(settingsManager.currentTheme.textColorOnPrimary)
                            .padding(.vertical, 4)
                            .padding(.horizontal , 8)
                            .background(settingsManager.currentTheme.primaryColor)
                            .clipShape(Capsule())
                    }
                    Spacer()
                }
                .padding(.horizontal, 2)
                            
                Spacer()
                
                Button("Зарегистрироваться") {
                    viewModel.attemptLogin()
                    debugPrint("Зарегистрироваться")
                }
                .buttonStyle(ConditionalButtonStyle(conditional: viewModel.canProceed))
                .disabled(!viewModel.canProceed)
                .animation(.easeInOut, value: viewModel.canProceed)
                .padding(.bottom, 6)
            }
            .padding(20)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
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
                    Text("Регистрация")
                        .font(.system(size: settingsManager.textSizeSettings.pageName))
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                }
            }
        }
        .sheet(isPresented: $presentActivitiesSheet) {
            NavigationStack {
                VStack {
                    SearchBarLight(text: $viewModel.searchText)
                        .padding(.top)
                        .padding(.horizontal, 10)
                    
                    List(viewModel.activityList) { activity in
                        HStack {
                            Text(activity.text)
                                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                            Spacer()
                        }
                        .listRowBackground(settingsManager.currentTheme.backgroundColor)
                        .onTapGesture {
                            viewModel.activity = activity.text
                            viewModel.isSelectedActivity = true
                            presentActivitiesSheet = false
                        }
                    }
                    .listStyle(.plain)
                    .overlay(Group {
                        if viewModel.activityList.isEmpty {
                            Text("Ничего не найдено...")
                                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                        }
                    })
                }
                .background(settingsManager.currentTheme.backgroundColor)
                .animation(.default, value: viewModel.activityList.isEmpty)
                .animation(.default, value: viewModel.searchText)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

struct RegView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .preferredColorScheme(.dark)
            .environmentObject(SettingsManager())
    }
}
