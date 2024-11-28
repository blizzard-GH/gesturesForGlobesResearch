//
//  TaskView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import SwiftUI

struct TaskView: View {
    @Environment(ViewModel.self) var model
    @Binding var currentPage: Page
    let taskNumber: Int
    
    var body: some View {
        VStack {
            Text("Start Task \(taskNumber)")
            GlobeButton(globe: model.globe)
                .padding()
#warning("This button is currently always visible, but it should only be shown once all tasks have been completed.")
            Button("Answer Questions") {
                currentPage = currentPage.next()
            }
        }
    }
}
