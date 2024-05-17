//
//  ProfileViewModel.swift
//  Collart
//
//  Created by Nik Y on 28.03.2024.
//

import Foundation

class ProfileViewModel: ObservableObject {
    static let shared = ProfileViewModel()
    
    @Published var specProfile: User
    @Published var shouldReloadOrders = false
    @Published var shouldReloadPortfolio = false
    
    init () {
        self.specProfile = UserManager.shared.user
    }
    
    func fetchUser(completion: @escaping (Bool) -> Void) {
        let language = LocalPersistence.shared.language
        NetworkService.fetchAuthenticatedUser(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    UserManager.shared.user = User(
                        id: data.user.id,
                        backgroundImage: data.user.cover ?? "",
                        avatar: data.user.userPhoto ?? "",
                        name: "\(data.user.name!)", 
                        surname: data.user.surname ?? "",
                        profession: data.skills.compactMap(
                            {
                                if $0.primary ?? false {
                                    return language == "ru" ? $0.nameRu : $0.nameEn
                                } else {
                                    return nil
                                }
                            }).joined(separator: ", "),
                        email: data.user.email ?? "",
                        subProfessions: data.skills.compactMap(
                            {
                                if !($0.primary ?? false) {
                                    return language == "ru" ? $0.nameRu : $0.nameEn
                                } else {
                                    return nil
                                }
                            }),
                        tools: data.tools,
                        searchable: data.user.searchable ?? false,
                        experience: data.user.experience ?? "no_experience",
                        activeProjects: UserManager.shared.user.activeProjects,
                        liked: UserManager.shared.user.liked
                    )
                    self.specProfile = UserManager.shared.user
                    completion(true)
                case .failure( _):
                    completion(false)
                }
            }
        })
    }
}
