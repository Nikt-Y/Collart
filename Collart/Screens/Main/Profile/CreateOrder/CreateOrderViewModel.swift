//
//  CreateOrderViewModel.swift
//  Collart
//

import SwiftUI

class CreateOrderViewModel: ObservableObject {
    @Environment(\.networkService) private var networkService: NetworkService
    @Published var name: String = ""
    @Published var requirement: String = ""
    @Published var description: String = ""
    @Published var activity: String = ""
    @Published var experience: String = ""
    @Published var tools: [String] = []
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(604800)
    @Published var image: UIImage? = nil
    @Published var fileUrls: [URL] = []
    
    @Published var isValidName: Bool = false
    @Published var isValidReq: Bool = false
    @Published var isValidDesc: Bool = false
    @Published var isSelectedActivity: Bool = false
    @Published var isSelectedExperience: Bool = false
    @Published var isStartDatePicked: Bool = false
    @Published var isEndDatePicked: Bool = false
    
    @Published var searchText: String = ""
    
    var isSelectedSoftware: Bool {
        !tools.isEmpty
    }
    
    private var orderService: OrderServiceDelegate {
        networkService
    }
    
    func submitOrder(completion: @escaping () -> ()) {
        let orderDetails = NetworkService.OrderForSend(
            title: name,
            skill: activity,
            taskDescription: requirement,
            projectDescription: description,
            experience: experience,
            dataStart: String(Int(startDate.timeIntervalSince1970)),
            dataEnd: String(Int(endDate.timeIntervalSince1970)),
            tools: tools
        )

        let orderForm = NetworkService.OrderForm(
            parameters: orderDetails,
            image: image,
            files: fileUrls.reduce(into: [String: URL]()) { result, url in result["file\(result.count + 1)"] = url }
        )

        orderService.addOrder(orderForm: orderForm) { success, error in
            if success {
                print("Order added successfully.")
            } else if let error = error {
                print("Error adding order: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    var activityList: [Skill] {
        if searchText.isEmpty {
            return Skill.skills
        } else {
            return Skill.skills.filter{ $0.text.lowercased().contains(searchText.lowercased())}
        }
    }
    
    var experienceList: [ExperienceFilter] {
        if searchText.isEmpty {
            return ExperienceFilter.experiences
        } else {
            return ExperienceFilter.experiences.filter{ $0.experience.text.lowercased().contains(searchText.lowercased())}
        }
    }
    
    var softwareList: [Tool] {
        if searchText.isEmpty {
            return Tool.tools
        } else {
            return Tool.tools.filter{ $0.text.lowercased().contains(searchText.lowercased())}
        }
    }
    
    @Published var isLoading = false
    
    var canProceed: Bool {
        return isValidName && isValidDesc && isValidReq && isSelectedActivity && isSelectedExperience && isSelectedSoftware
    }
}
