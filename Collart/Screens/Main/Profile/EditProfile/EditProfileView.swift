import SwiftUI

struct EditProfileView: View {
    @StateObject private var viewModel: EditProfileViewModel
    @State private var presentProfessionSheet: Bool = false
    @State private var presentSubProfessionSheet: Bool = false
    @State private var presentExperienceSheet: Bool = false
    @State private var selectedSubProfessionIndex: Int?
    
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
                            errorText: "Неверный формат почты"
                        )
                        .padding(.bottom, 3)
                        
                        Button {
                            presentProfessionSheet = true
                        } label: {
                            HStack {
                                if viewModel.profession.isEmpty {
                                    Text("Основная специальность")
                                } else {
                                    Text("\(viewModel.profession)")
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: !viewModel.profession.isEmpty), lineWidth: 1))
                            .foregroundColor(settingsManager.currentTheme.selectedTextColor(isSelected: !viewModel.profession.isEmpty))
                            .font(.system(size: settingsManager.textSizeSettings.body))
                        }
                        .padding(.bottom, 3)
                        
                        ForEach(viewModel.subProfessions.indices, id: \.self) { index in
                            Button {
                                selectedSubProfessionIndex = index
                                presentSubProfessionSheet = true
                            } label: {
                                HStack {
                                    if viewModel.subProfessions[index].isEmpty {
                                        Text("Дополнительная специальность \(index + 1)")
                                    } else {
                                        Text("\(viewModel.subProfessions[index])")
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settingsManager.currentTheme.selectedTextColor(isSelected: !viewModel.subProfessions[index].isEmpty), lineWidth: 1))
                                .foregroundColor(settingsManager.currentTheme.selectedTextColor(isSelected: !viewModel.subProfessions[index].isEmpty))
                                .font(.system(size: settingsManager.textSizeSettings.body))
                            }
                            .padding(.bottom, 3)
                        }
                        
                        if viewModel.subProfessions.count < 2 {
                            HStack {
                                Button {
                                    viewModel.subProfessions.append("")
                                } label: {
                                    Text("Добавить специальность")
                                        .foregroundColor(settingsManager.currentTheme.textColorOnPrimary)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(settingsManager.currentTheme.primaryColor)
                                        .clipShape(Capsule())
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 2)
                            .padding(.bottom, 3)
                        }
                        
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
        .sheet(isPresented: $presentProfessionSheet) {
            SkillSelectionView(skills: $viewModel.skills) { selectedSkill in
                viewModel.profession = selectedSkill
                presentProfessionSheet = false
            }
        }
        .sheet(isPresented: $presentSubProfessionSheet) {
            if let index = selectedSubProfessionIndex {
                SkillSelectionView(skills: $viewModel.skills) { selectedSkill in
                    viewModel.subProfessions[index] = selectedSkill
                    presentSubProfessionSheet = false
                }
            }
        }
        .sheet(isPresented: $presentExperienceSheet) {
            ExperienceSelectionView(experiences: ExperienceFilter.experiences.map { $0.experience }) { selectedExperience in
                viewModel.experience = selectedExperience
                presentExperienceSheet = false
            }
        }
        .sheet(isPresented: $viewModel.showToolSheet) {
            ToolSelectionView(tools: $viewModel.tools)
        }
    }
}

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

struct ExperienceSelectionView: View {
    let experiences: [Experience]
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
                    if experience == experiences.first(where: { $0.text == experience.text }) {
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

struct ToolSelectionView: View {
    @Binding var tools: [Tool]
    
    var body: some View {
        VStack {
            Text("Выберите инструменты")
                .font(.headline)
                .padding()
            
            List {
                ForEach($tools) { $tool in
                    HStack {
                        Text(tool.text)
                        Spacer()
                        if tool.isSelected {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tool.isSelected.toggle()
                    }
                }
            }
        }
    }
}
