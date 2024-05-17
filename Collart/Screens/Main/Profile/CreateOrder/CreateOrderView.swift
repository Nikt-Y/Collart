//
//  CreateOrderView.swift
//  Collart
//
//  Created by Nik Y on 23.04.2024.
//

import SwiftUI

struct CreateOrderView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = CreateOrderViewModel()
    @State var presentActivitiesSheet = false
    @State var presentExperienceSheet = false
    @State var presentSoftwareSheet = false
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
                    
                    Button {
                        presentActivitiesSheet = true
                        hideKeyboard()
                    } label: {
                        HStack {
                            if viewModel.activity.isEmpty {
                                Text("Какого специалиста ищете")
                            } else {
                                Text("\(viewModel.activity)")
                            }
                            Spacer()
                            Image("arrowDown")
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settings.currentTheme.selectedTextColor(isSelected: !viewModel.activity.isEmpty), lineWidth: 1))
                        .foregroundColor(settings.currentTheme.selectedTextColor(isSelected: !viewModel.activity.isEmpty))
                        .font(.system(size: settings.textSizeSettings.body))
                    }
                    .padding(.bottom, 3)
                    
                    TextErrorField(
                        placeHolder: "Кратко опишите задачу",
                        fieldText: $viewModel.requirement,
                        isValid: $viewModel.isValidReq
                    )
                    .padding(.bottom, 6)

                    
                    TextErrorEditor(
                        placeHolder: "Расскажите подробнее о проекте",
                        fieldText: $viewModel.description,
                        isValid: $viewModel.isValidDesc
                    )
                    .padding(.bottom, 3)
                    
                    Button {
                        presentExperienceSheet = true
                        hideKeyboard()
                    } label: {
                        HStack {
                            Text(viewModel.experience.isEmpty ? "Опыт работы" : Experience.fromString(viewModel.experience).text)
                            Spacer()
                            Image("arrowDown")
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settings.currentTheme.selectedTextColor(isSelected: !viewModel.experience.isEmpty), lineWidth: 1))
                        .foregroundColor(settings.currentTheme.selectedTextColor(isSelected: !viewModel.experience.isEmpty))
                    }
                    
                    Button {
                        presentSoftwareSheet = true
                        hideKeyboard()
                    } label: {
                        HStack {
                            Text(viewModel.tools.isEmpty ? "Программы" : viewModel.tools.joined(separator: ", "))
                                .lineLimit(1)
                            Spacer()
                            Image("arrowDown")
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 100).strokeBorder(settings.currentTheme.selectedTextColor(isSelected: !viewModel.tools.isEmpty), lineWidth: 1))
                        .foregroundColor(settings.currentTheme.selectedTextColor(isSelected: !viewModel.tools.isEmpty))
                    }
                    
                    HStack {
                        VStack {
                            Text("Дата начала")
                                .font(.headline)
                            DateErrorPicker(selectedDate: $viewModel.startDate, isValid: $viewModel.isStartDatePicked, errorText: "Неверная дата")
                        }
                        Spacer()
                        VStack {
                            Text("Дата окончания")
                                .font(.headline)
                            DateErrorPicker(selectedDate: $viewModel.endDate, isValid: $viewModel.isEndDatePicked, errorText: "Неверная дата")
                        }
                    }
                    .padding(.vertical, 5)
                    
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
                viewModel.submitOrder {
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
            .buttonStyle(ConditionalButtonStyle(conditional: viewModel.isSelectedSoftware))
            .disabled(!viewModel.isSelectedSoftware)
            .animation(.easeInOut, value: viewModel.isSelectedSoftware)
            .padding()
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
                    Text("Создать заказ")
                        .font(.system(size: settings.textSizeSettings.pageName))
                        .foregroundColor(settings.currentTheme.textColorPrimary)
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
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                            Spacer()
                        }
                        .listRowBackground(settings.currentTheme.backgroundColor)
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
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                        }
                    })
                }
                .onAppear {
                    viewModel.searchText = ""
                }
                .background(settings.currentTheme.backgroundColor)
                .animation(.default, value: viewModel.activityList.isEmpty)
                .animation(.default, value: viewModel.searchText)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $presentExperienceSheet) {
            NavigationStack {
                VStack {
                    SearchBarLight(text: $viewModel.searchText)
                        .padding(.top)
                        .padding(.horizontal, 10)
                    
                    List(viewModel.experienceList) { exp in
                        HStack {
                            Text(exp.experience.text)
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                            Spacer()
                        }
                        .listRowBackground(settings.currentTheme.backgroundColor)
                        .onTapGesture {
                            viewModel.experience = exp.experience.rawValue
                            viewModel.isSelectedExperience = true
                            presentExperienceSheet = false
                        }
                    }
                    .listStyle(.plain)
                    .overlay(Group {
                        if viewModel.experienceList.isEmpty {
                            Text("Ничего не найдено...")
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                        }
                    })
                }
                .onAppear {
                    viewModel.searchText = ""
                }
                .background(settings.currentTheme.backgroundColor)
                .animation(.default, value: viewModel.experienceList.isEmpty)
                .animation(.default, value: viewModel.searchText)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $presentSoftwareSheet) {
            NavigationStack {
                ToolSelectionView(tools: $viewModel.tools)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    CreateOrderView()
        .environmentObject(SettingsManager())
}
