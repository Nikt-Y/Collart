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
    @State private var selectedSkillIndex: Int?

    @EnvironmentObject var settingsManager: SettingsManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            settingsManager.currentTheme.backgroundColor
                .ignoresSafeArea()

            VStack {
                ScrollView {
                    VStack {
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
                            errorText: "Неверный формат почты",
                            autocapitalization: false
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

                        ForEach(Array(viewModel.skills.enumerated()), id: \.element) { index, skill in
                            Button {
                                selectedSkillIndex = index
                                presentActivitiesSheet = true
                            } label: {
                                HStack {
                                    Text(skill.isEmpty ? "Выберите специальность" : skill)

                                    Spacer()

                                    Image("arrowDown")
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: !skill.isEmpty), lineWidth: 1))
                                .foregroundColor(settingsManager.currentTheme.selectedTextColor(isSelected: !skill.isEmpty))
                                .font(.system(size: settingsManager.textSizeSettings.body))
                            }
                            .padding(.bottom, 3)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }

                        HStack {
                            if viewModel.skills.count < 3 {
                                Button {
                                    withAnimation {
                                        viewModel.addSkill()
                                    }
                                } label: {
                                    Text("Добавить специальность")
                                        .foregroundColor(settingsManager.currentTheme.textColorOnPrimary)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(settingsManager.currentTheme.primaryColor)
                                        .clipShape(Capsule())
                                }
                            }
                            Spacer()

                            if viewModel.skills.count > 1 {
                                Button {
                                    withAnimation {
                                        viewModel.removeSkill()
                                    }
                                } label: {
                                    Text(viewModel.skills.count < 3 ? "Убрать" : "Убрать специальность")
                                        .foregroundColor(settingsManager.currentTheme.textColorOnPrimary)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(Color.red)
                                        .clipShape(Capsule())
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                    .padding(20)
                    .padding(.top, 30)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }

                Button("Зарегистрироваться") {
                    hideKeyboard()
                    viewModel.attemptLogin()
                    debugPrint("Зарегистрироваться")
                }
                .buttonStyle(ConditionalButtonStyle(conditional: viewModel.canProceed))
                .disabled(!viewModel.canProceed)
                .animation(.easeInOut, value: viewModel.canProceed)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
            }
            .onTapGesture {
                hideKeyboard()
            }

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
        .toolbarBackground(settingsManager.currentTheme.backgroundColor, for: .navigationBar) // Prevents toolbar color change on scroll
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

                    List(viewModel.skillList) { activity in
                        HStack {
                            Text(activity.text)
                                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                            Spacer()
                        }
                        .contentShape(Rectangle()) // Makes the entire row tappable
                        .listRowBackground(settingsManager.currentTheme.backgroundColor)
                        .onTapGesture {
                            if let index = selectedSkillIndex {
                                viewModel.skills[index] = activity.text
                            } else {
                                viewModel.skills.append(activity.text)
                            }
                            viewModel.isSelectedActivity = true
                            presentActivitiesSheet = false
                        }
                    }
                    .listStyle(.plain)
                    .overlay(Group {
                        if viewModel.skillList.isEmpty {
                            Text("Ничего не найдено...")
                                .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                        }
                    })
                }
                .background(settingsManager.currentTheme.backgroundColor)
                .animation(.default, value: viewModel.skillList.isEmpty)
                .animation(.default, value: viewModel.searchText)
                .onAppear {
                    viewModel.searchText = ""
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}
