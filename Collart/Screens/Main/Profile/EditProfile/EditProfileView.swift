//
//  EditProfileView.swift
//  Collart
//

import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    @State private var presentSkillsSheet: Bool = false
    @State private var presentExperienceSheet: Bool = false
    @State private var selectedSkillIndex: Int?
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }
    
    var body: some View {
        ZStack {
            settingsManager.currentTheme.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                
                ScrollView {
                    VStack {
                        Spacer()
                        
                        TextErrorField(
                            placeHolder: "Имя",
                            fieldText: $viewModel.name,
                            isValid: $viewModel.isValidName,
                            validateMethod: Validator.validateName,
                            errorText: "Введите имя"
                        )
                        .padding(.bottom, 3)
                        
                        TextErrorField(
                            placeHolder: "Фамилия",
                            fieldText: $viewModel.surname,
                            isValid: .constant(true),
                            validateMethod: { _ in true },
                            errorText: ""
                        )
                        .padding(.bottom, 3)
                        
                        TextErrorField(
                            placeHolder: "Почта",
                            fieldText: $viewModel.email,
                            isValid: $viewModel.isValidEmail,
                            validateMethod: Validator.validateEmail,
                            errorText: "Неверный формат почты",
                            autocapitalization: false
                        )
                        .padding(.bottom, 3)
                        
                        ForEach(Array(viewModel.skills.enumerated()), id: \.element) { index, skill in
                            Button {
                                selectedSkillIndex = index
                                presentSkillsSheet = true
                            } label: {
                                HStack {
                                    Text(skill.isEmpty ? "Выберите специальность" : skill)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
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
                        
                        Toggle("Хотите быть видимым в списке специалистов?", isOn: $viewModel.searchable)
                            .padding(.bottom, 3)
                        
                        PasswordField(
                            placeHolder: "Новый пароль",
                            fieldText: $viewModel.password,
                            isValid: .constant(true),
                            validateMethod: { _ in true },
                            errorText: ""
                        )
                        .padding(.bottom, 3)
                        
                        VStack {
                            HStack {
                                Text("Аватар")
                                    .font(.headline)
                                Spacer()
                            }
                            ImagePickerField(image: $viewModel.image)
                        }
                        .padding(.bottom, 3)
                        
                        VStack {
                            HStack {
                                Text("Обложка")
                                    .font(.headline)
                                Spacer()
                            }
                            ImagePickerField(image: $viewModel.cover)
                        }
                        .padding(.bottom, 3)
                        
                        Button {
                            presentExperienceSheet = true
                        } label: {
                            HStack {
                                if viewModel.experience.text.isEmpty {
                                    Text("Опыт")
                                } else {
                                    Text("\(viewModel.experience.text)")
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: !viewModel.experience.text.isEmpty), lineWidth: 1))
                            .foregroundColor(settingsManager.currentTheme.selectedTextColor(isSelected: !viewModel.experience.text.isEmpty))
                            .font(.system(size: settingsManager.textSizeSettings.body))
                        }
                        .padding(.bottom, 3)
                        
                        Button {
                            viewModel.showToolSheet.toggle()
                        } label: {
                            HStack {
                                Text("Инструменты")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: true), lineWidth: 1))
                            .foregroundColor(settingsManager.currentTheme.selectedTextColor(isSelected: true))
                            .font(.system(size: settingsManager.textSizeSettings.body))
                        }
                        .padding(.bottom, 3)
                        
                        Button {
                            UserManager.shared.setToken(newToken: nil)
                        } label: {
                            Text("Выйти из аккаунта")
                                .bold()
                                .padding()
                                .background(Color(hex: "FF1E00"))
                                .foregroundColor(.white)
                                .font(.system(size: settingsManager.textSizeSettings.body))
                                .clipShape(Capsule())
                        }
                        .padding(.bottom, 3)
                    }
                    .padding(20)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                Button("Сохранить изменения") {
                    viewModel.saveChanges { success, error in
                        if success {
                            dismiss()
                        } else {
                            print("Ошибка сохранения изменений")
                        }
                    }
                }
                .buttonStyle(ConditionalButtonStyle(conditional: viewModel.canProceed))
                .disabled(!viewModel.canProceed)
                .animation(.easeInOut, value: viewModel.canProceed)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(settingsManager.currentTheme.backgroundColor)
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
        .onTapGesture {
            hideKeyboard()
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
                    Text("Редактирование профиля")
                        .font(.system(size: settingsManager.textSizeSettings.pageName))
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                }
            }
        }
        .sheet(isPresented: $presentSkillsSheet) {
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
                        .contentShape(Rectangle())
                        .listRowBackground(settingsManager.currentTheme.backgroundColor)
                        .onTapGesture {
                            if let index = selectedSkillIndex {
                                viewModel.skills[index] = activity.text
                            } else {
                                viewModel.skills.append(activity.text)
                            }
                            presentSkillsSheet = false
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
        .sheet(isPresented: $presentExperienceSheet) {
            NavigationStack {
                ExperienceSelectionView(experiences: ExperienceFilter.experiences.map { $0.experience }, selectedExperience: viewModel.experience) { selectedExperience in
                    viewModel.experience = selectedExperience
                    presentExperienceSheet = false
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showToolSheet) {
            NavigationStack {
                ToolSelectionView(tools: $viewModel.tools)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - SkillSelectionView
struct SkillSelectionView: View {
    @Binding var skills: [Skill]
    var onSelect: ((String) -> Void)? = nil
    
    var body: some View {
        VStack {
            Text("Выберите специальность")
                .font(.headline)
                .padding()
            
            List {
                ForEach($skills) { $skill in
                    HStack {
                        Text(skill.text)
                        Spacer()
                        if skill.isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        skill.isSelected.toggle()
                        onSelect?(skill.text)
                    }
                }
            }
        }
    }
}

// MARK: - ExperienceSelectionView
struct ExperienceSelectionView: View {
    let experiences: [Experience]
    var selectedExperience: Experience
    var onSelect: ((Experience) -> Void)? = nil
    
    var body: some View {
        VStack {
            Text("Выберите опыт")
                .font(.headline)
                .padding()
            
            List(experiences, id: \.self) { experience in
                HStack {
                    Text(experience.text)
                    Spacer()
                    if experience == selectedExperience {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect?(experience)
                }
            }

        }
    }
}

// MARK: - ToolSelectionView
struct ToolSelectionView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @Binding var tools: [String]
    @State private var searchText: String = ""
    
    var filteredTools: [Tool] {
        if searchText.isEmpty {
            return Tool.tools
        } else {
            return Tool.tools.filter { $0.text.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack {
            Text("Выберите инструмент")
                .font(.headline)
                .padding()
            
            SearchBarLight(text: $searchText)
                .padding(.horizontal, 10)
            
            List(filteredTools, id: \.id) { tool in
                HStack {
                    Text(tool.text)
                    Spacer()
                    if tools.contains(where: { $0 == tool.text }) {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(settingsManager.currentTheme.backgroundColor)
                .onTapGesture {
                    if let index = tools.firstIndex(where: { $0 == tool.text }) {
                        tools.remove(at: index)
                    } else {
                        tools.append(tool.text)
                    }
                }
            }
            .listStyle(.plain)
            .overlay(Group {
                if filteredTools.isEmpty {
                    Text("Ничего не найдено...")
                        .foregroundColor(settingsManager.currentTheme.textColorPrimary)
                }
            })
        }
        .background(settingsManager.currentTheme.backgroundColor)
        .animation(.default, value: filteredTools.isEmpty)
        .animation(.default, value: searchText)
    }
}
