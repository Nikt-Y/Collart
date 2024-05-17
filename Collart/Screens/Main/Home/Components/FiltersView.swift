//
//  FiltersView.swift
//  Collart
//
//  Created by Nik Y on 09.03.2024.
//

import SwiftUI

struct FiltersView: View {
    @EnvironmentObject var settings: SettingsManager
    @ObservedObject var viewModel: HomeViewModel
    @Binding var isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Button(action: {
                    isActive = false
                }, label: {
                    Image(systemName: "multiply")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .foregroundColor(settings.currentTheme.textColorPrimary)
                })
                
                Text("Фильтры")
                    .font(.system(size: settings.textSizeSettings.pageName))
                    .foregroundColor(settings.currentTheme.textColorPrimary)
                    .padding(.leading, 5)
                
                Spacer()
                
                Button("Сбросить") {
                    viewModel.resetFilters()
                }
                .font(.system(size: settings.textSizeSettings.semiPageName))
                .foregroundColor(viewModel.isFiltersSelected ? settings.currentTheme.primaryColor : settings.currentTheme.textColorLightPrimary)
                .disabled(!viewModel.isFiltersSelected)
                .animation(.default, value: viewModel.isFiltersSelected)
            }
            .padding()
            
            Group {
                Text("Сфера деятельности")
                    .font(.system(size: settings.textSizeSettings.pageName))
                    .bold()
                    .foregroundColor(settings.currentTheme.textColorPrimary)
                    .padding(.horizontal)
                
                SearchBarLight(text: $viewModel.specialtySearchText)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(viewModel.filteredSpecialtyFilters, id: \.id) { filter in
                            FilterCell(isSelected: filter.isSelected, text: filter.text)
                                .padding(.leading, filter == viewModel.filteredSpecialtyFilters.first ? 10 : 0)
                                .padding(.trailing, filter == viewModel.filteredSpecialtyFilters.last ? 10 : 0)
                                .onTapGesture {
                                    viewModel.selectSpecialty(filter)
                                }
                        }
                    }
                    // костылек, но LazyHStack не хочет нормально работать
                    .frame(height: settings.textSizeSettings.body + 30)
                }
                .animation(.default, value: viewModel.filteredSpecialtyFilters)
            }
            .padding(.bottom, 5)
            
            Group {
                Text("Опыт работы")
                    .font(.system(size: settings.textSizeSettings.pageName))
                    .bold()
                    .foregroundColor(settings.currentTheme.textColorPrimary)
                    .padding(.horizontal)
                
                SearchBarLight(text: $viewModel.experienceSearchText)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(viewModel.filteredExperienceFilters, id: \.id) { filter in
                            FilterCell(isSelected: filter.isSelected, text: filter.text)
                                .padding(.leading, filter == viewModel.filteredExperienceFilters.first ? 10 : 0)
                                .padding(.trailing, filter == viewModel.filteredExperienceFilters.last ? 10 : 0)
                                .onTapGesture {
                                    viewModel.selectExperience(filter)
                                }
                        }
                    }
                    .frame(height: settings.textSizeSettings.body + 30)
                }
                .animation(.default, value: viewModel.filteredExperienceFilters)
            }
            .padding(.bottom, 5)
            
            Group {
                Text("Программы")
                    .font(.system(size: settings.textSizeSettings.pageName))
                    .bold()
                    .foregroundColor(settings.currentTheme.textColorPrimary)
                    .padding(.horizontal)
                
                SearchBarLight(text: $viewModel.toolSearchText)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(viewModel.filteredToolFilters, id: \.id) { filter in
                            FilterCell(isSelected: filter.isSelected, text: filter.text)
                                .padding(.leading, filter == viewModel.filteredToolFilters.first ? 10 : 0)
                                .padding(.trailing, filter == viewModel.filteredToolFilters.last ? 10 : 0)
                                .onTapGesture {
                                    viewModel.selectTool(filter)
                                }
                        }
                    }
                    .frame(height: settings.textSizeSettings.body + 30)
                }
                .animation(.default, value: viewModel.filteredToolFilters)
            }
            
            Spacer()
            
            Button("Применить") {
//                viewModel.fetchDataWithFilters()
                isActive = false
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isFiltersSelected)
            .animation(.easeInOut, value: viewModel.isFiltersSelected)
            .padding()
        }
    }
}

//struct FiltersView_Previews: PreviewProvider {
//    static var previews: some View {
//        FiltersView(viewModel: HomeViewModel(), isActive: true)
//            .environmentObject(SettingsManager())
//    }
//}
