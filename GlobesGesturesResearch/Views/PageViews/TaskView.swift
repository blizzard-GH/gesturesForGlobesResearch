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
//    @State private var isCurrentTaskMatched: Bool = false
    private func updateAttachmentView() {
            switch currentPage {
            case .positionExperimentForm:
                model.attachmentView = .position
            case .scaleExperimentForm:
                model.attachmentView = .scale
            default:
                model.attachmentView = .none
            }
        }
    
    
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
//                            Task{
//                                await checkMatchingStatus(taskNumber : details.taskNumber, model: model)
//                            }
                        }
                    } else {
                        if studyModel.currentTask?.isMatching == true {
//                        if studyModel.getMatcher(taskNumber: details.taskNumber, model: model) {
                            Text("Matched!")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding()
                        }
                        Text("Time elapsed: \(String(format: "%.2f", elapsedTime)) seconds")
                            .font(.title)
                            .monospacedDigit()
                            .padding()
                        //Below is for debugging only
//                        Text("currentPge: \(currentPage)")
//                        Text("Is storing needed \(currentPage.isStoringRecordNeeded)")
//                        Text("current task: \(studyModel.currentTask?.accuracyResult ?? 0.0)")
//                        Text("is matching: \(studyModel.currentTask?.isMatching ?? false)")
//                        Text("Last used index: \(PositionCondition.lastUsedPositionConditionIndex)")
//                        Text("Is conditions looping complete: \(PositionCondition.positionConditionsCompleted)")

                        
                        Instruction()
                        if studyModel.proceedToNextExperiment {
                            Button(
                                "Finish \(details.description), and move to the next task."
                            ) {
                                currentPage = currentPage.next()
                                studyModel.proceedToNextExperiment = false
                                //                            studyModel.currentTaskPage = currentPage
                                isDoingTask = false
                                showTaskContent = false
                                showOrHideGlobe(false)
                                stopTimer()
                            }
                        }
                    }
                }
            } else {
                Text("Invalid Task")
                    .foregroundColor(.red)
            }
        }
        .onAppear{
            updateAttachmentView()
            showOrHideGlobe(false)
        }
        .onDisappear{
            showOrHideGlobe(false)
        }
    }
    
//    func checkMatchingStatus(taskNumber: Int, model: ViewModel) async {
//        isCurrentTaskMatched = studyModel.getMatcher(taskNumber: taskNumber, model: model)
//    }
    
    
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
        Task { @MainActor in
            if show {
                guard !model.configuration.isVisible else { return }
                model.load(
                        firstGlobe: model.globe,
                        secondGlobe: model.secondGlobe,
                        openImmersiveSpaceAction: openImmersiveSpaceAction
                    )
            } else {
                guard model.configuration.isVisible else { return }
                model.hideGlobe()
            }
        }
    }
}

