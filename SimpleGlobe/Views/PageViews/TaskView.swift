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
    
    @State private var isDoingTask: Bool = false
    
    var body: some View {
        VStack {
            if let details = currentPage.taskDetails {
                Text("""
                We are about to start task \(details.taskNumber)
                It will measure time immediately after you click the button below.
                Whenever you are ready, click the button below and do as instructed.
                
                \(details.instructions)
                """)
                .multilineTextAlignment(.center)
                GlobeButton(firstGlobe: model.globe, secondGlobe: model.secondGlobe, isDoingTask: $isDoingTask)
                    .padding()
#warning("This button is currently always visible, but it should only be shown once all tasks have been completed.")
                Button("Answer Questions about Task \(details.taskNumber)") {
                    currentPage = currentPage.next()
                    isDoingTask = false
                }
            } else {
                Text("Invalid Task")
                    .foregroundColor(.red)
            }
        }
    }
}
