//
//  DetailSpecialitstView.swift
//  Collart
//
//  Created by Nik Y on 20.03.2024.
//

import SwiftUI

import SwiftUI

struct DetailSpecialitstView: View {
    @StateObject private var viewModel = DetailSpecialitstViewModel()
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    let specialist: Specialist
    
    init(specialist: Specialist) {
        self.specialist = specialist
        viewModel.specialist = specialist
    }
    
    var body: some View {
        VStack {
            
        }
    }
}

struct DetailSpecialitstView_Previews: PreviewProvider {
    static var previews: some View {
        DetailSpecialitstView(specialist: Specialist(backgroundImage: URL(string: "https://example.com/projectImage1.png")!, specImage: URL(string: "https://example.com/projectImage1.png")!, name: "Test Name", profession: "Test profession", experience: "Test experience", tools: "Tool test 1, tool test 2"))
    }
}
