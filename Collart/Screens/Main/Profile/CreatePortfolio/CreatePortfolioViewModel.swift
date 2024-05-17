//
//  CreatePortfolioViewModel.swift
//  Collart
//

import SwiftUI

class CreatePortfolioViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var image: UIImage? = nil
    @Published var fileUrls: [URL] = []
    
    @Published var isValidName: Bool = false
    @Published var isValidDesc: Bool = false
    
    @Published var isLoading = false
    
    private var profileService: ProfileServiceDelegate {
        networkService
    }
    
    func submitPortfolio(completion: @escaping () -> ()) {
        let portfolioDetails = NetworkService.PortfolioProjectParameters(
            name: name,
            description: description
        )

        let portfolioForm = NetworkService.PortfolioProjectForm(
            parameters: portfolioDetails,
            image: image,
            files: fileUrls.reduce(into: [String: URL]()) { result, url in result["file\(result.count + 1)"] = url }
        )

        profileService.addPortfolio(portfolioForm: portfolioForm) { success, error in
            if success {
                print("Portfolio added successfully.")
            } else if let error = error {
                print("Error adding portfolio: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    var canProceed: Bool {
        return isValidName && isValidDesc
    }
}

