//
//  DetailSpecialitstViewModel.swift
//  Collart
//
//  Created by Nik Y on 20.03.2024.
//

import Foundation

final class DetailSpecialitstViewModel: ObservableObject {
    @Published var specProfile: User
    @Published var showInviteSelect = false
    @Published var selectedProjectsForInvite: [Order] = []
    
    init (specProfile: Specialist) {
        self.specProfile = User(
            id: specProfile.id,
            backgroundImage: specProfile.backgroundImage,
            avatar: specProfile.specImage,
            name: "\(specProfile.name)",
            surname: "",
            profession: specProfile.profession,
            email: specProfile.email,
            subProfessions: [specProfile.subProfession],
            tools: [],
            searchable: false,
            experience: "no_experience"
        )
    }
}
