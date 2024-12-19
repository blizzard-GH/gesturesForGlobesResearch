//
//  TaskView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import SwiftUI

struct TaskView: View {
    @Environment(ViewModel.self) var model
    @Environment(StudyModel.self) var studyModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    
    @Binding var currentPage: Page
    @State private var isDoingTask: Bool = false
    @State private var elapsedTime: Double = 0
    @State private var timer: Timer? = nil
    @State private var startTime: Date? = nil
    @State private var showTaskContent: Bool = false
    
    var body: some View {
        VStack {
            if let details = currentPage.taskDetails {
                if !isDoingTask {
                    Text("""
                We are about to start task \(details.taskNumber)
                It will measure time immediately after you click the button below.
                Whenever you are ready, click the button below and do as instructed.
                
                \(details.instructions)
                """)
                    .multilineTextAlignment(.center)
                    StartTaskButton(isDoingTask: $isDoingTask)
                        .padding()
                }
                else {
                    if !showTaskContent {
                        GetReady{
                            showTaskContent = true
                            showOrHideGlobe(true)
                            startTimer()
                        }
                    } else {
                        if studyModel.positionMatcher.isPositionMatched {
                            Text("Position matched!")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding()
                        }
                        Text("Time elapsed: \(String(format: "%.2f", elapsedTime)) seconds")
                            .font(.title)
                            .monospacedDigit()
                            .padding()
                        Instruction()
                        Button(
                            "Answer Questions about Task \(details.taskNumber)"
                        ) {
                            currentPage = currentPage.next()
                            isDoingTask = false
                            showTaskContent = false
                            showOrHideGlobe(false)
                        }
                    }
                }
            } else {
                Text("Invalid Task")
                    .foregroundColor(.red)
            }
        }
    }
    
    func startTimer() {
        elapsedTime = 0
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @MainActor
    private func showOrHideGlobe(_ show: Bool) {
#warning("the `show` parameter is not used")
        Task { @MainActor in
            if model.configuration.isVisible {
                model.hideGlobe()
            } else {
                model
                    .load(
                        firstGlobe: model.globe,
                        secondGlobe: model.secondGlobe,
                        openImmersiveSpaceAction: openImmersiveSpaceAction
                    )
            }
        }
    }
}

