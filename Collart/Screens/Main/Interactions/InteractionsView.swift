//
//  InteractionsView.swift
//  Collart
//
//  Created by Nik Y on 17.03.2024.
//

import SwiftUI

enum InteractionTab: Pickable, CaseIterable {
    case responses, invitations
    
    var displayValue: String {
        switch self {
        case .responses: return "Отклики"
        case .invitations: return "Приглашения"
        }
    }
}


enum InteractionFilter: String, CaseIterable {
    case active = "Активные"
    case completed = "Завершенные"
    
    var displayValue: String {
        switch self {
        case .active: return "Активные"
        case .completed: return "Завершенные"
        }
    }
}

struct InteractionsView: View {
    @EnvironmentObject private var settings: SettingsManager
    @StateObject private var viewModel = InteractionsViewModel()
    @State var selectedTab: InteractionTab = .responses
    @State var selectedFilter: InteractionFilter = .active
    @State var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: settings.currentTheme.primaryColor))
                    .scaleEffect(2)
                    .animation(.default, value: isLoading)
                    .onAppear {
                        viewModel.fetchInteractions {
                            DispatchQueue.main.async {
                                isLoading = false
                            }
                        }
                    }
            } else {
                Text("Отклики и приглашения")
                    .font(.system(size: settings.textSizeSettings.pageName))
                    .bold()
                    .foregroundColor(settings.currentTheme.textColorPrimary)
                    .padding(.horizontal)
                
                CustomPicker(selectedTab: $selectedTab)
                
                Picker("Фильтр", selection: $selectedFilter) {
                    ForEach(InteractionFilter.allCases, id: \.self) { filter in
                        Text(filter.displayValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                List {
                    switch selectedTab {
                    case .responses:
                        ForEach(viewModel.responses.filter { response in
                            filterInteraction(response.status)
                        }, id: \.id) { response in
                            ResponseCell(id: response.id, responser: response.responser, project: response.project, status: response.status)
                        }
                        
                    case .invitations:
                        ForEach(viewModel.invites.filter { invite in
                            filterInteraction(invite.status)
                        }, id: \.id) { invite in
                            InvitationCell(id: invite.id, project: invite.project, status: invite.status)
                        }
                    }
                }
                .animation(.easeInOut, value: selectedTab)
                .listStyle(.plain)
                .overlay(Group {
                    switch selectedTab {
                    case .responses:
                        if viewModel.responses.isEmpty {
                            Text("У вас нет откликов")
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                        }
                        
                    case .invitations:
                        if viewModel.invites.isEmpty {
                            Text("У вас нет приглашений")
                                .foregroundColor(settings.currentTheme.textColorPrimary)
                        }
                    }
                })
            }
        }
        .background(settings.currentTheme.backgroundColor)
        .animation(.default, value: isLoading)
        .onAppear {
            isLoading = true
        }
    }
    
    private func filterInteraction(_ status: InteractionStatus) -> Bool {
        switch selectedFilter {
        case .active:
            return status == .active
        case .completed:
            return status == .accepted || status == .rejected
        }
    }
}

struct InteractionsView_Previews: PreviewProvider {
    static var previews: some View {
        InteractionsView()
            .environmentObject(SettingsManager())
    }
}
