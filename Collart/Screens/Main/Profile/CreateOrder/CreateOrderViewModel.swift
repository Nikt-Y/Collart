//
//  CreateOrderViewModel.swift
//  Collart
//
//  Created by Nik Y on 23.04.2024.
//

import Foundation
import UIKit

class CreateOrderViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var requirement: String = ""
    @Published var description: String = ""
    @Published var activity: String = ""
    @Published var experience: String = ""
    @Published var software: String = ""
    @Published var startDate = Date()
    @Published var endDate = Date().addingTimeInterval(604800)
    @Published var image: UIImage? = nil
    @Published var fileUrls: [URL] = []
    
    @Published var isValidName: Bool = false
    @Published var isValidReq: Bool = false
    @Published var isValidDesc: Bool = false
    @Published var isSelectedActivity: Bool = false
    @Published var isSelectedExperience: Bool = false
    @Published var isSelectedSoftware: Bool = false
    @Published var isStartDatePicked: Bool = false
    @Published var isEndDatePicked: Bool = false
    
    @Published var searchText: String = ""
    
    func submitOrder(completion: @escaping () -> ()) {
        let orderDetails = OrderForSend(
            title: name,
            skill: activity,
            taskDescription: requirement,
            projectDescription: description,
            experience: experience,
            dataStart: String(Int(startDate.timeIntervalSince1970)),
            dataEnd: String(Int(endDate.timeIntervalSince1970)),
            tools: [software]
        )

        let orderForm = OrderForm(
            parameters: orderDetails,
            image: image,
            files: fileUrls.reduce(into: [String: URL]()) { result, url in result["file\(result.count + 1)"] = url }
        )

        NetworkService.addOrder(orderForm: orderForm) { success, error in
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
