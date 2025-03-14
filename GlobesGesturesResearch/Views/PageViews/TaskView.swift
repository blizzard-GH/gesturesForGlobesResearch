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
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction
    
    @Binding var currentPage: Page
    @State private var isDoingTask: Bool = false
    @State private var elapsedTime: Double = 0
    @State private var timer: Timer? = nil
    @State private var startTime: Date? = nil
    @State private var showTaskContent: Bool = false
//    @State private var isCurrentTaskMatched: Bool = false
    private func updateAttachmentView() {
            switch currentPage {
            case .positionComparison:
                model.attachmentView = .position
            case .scaleComparison:
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
                We are about to start \(details.mainFeature) experiment \(details.taskNumber)
                The measurement will begin immediately after you click the button below.
                Whenever you are ready, click the button 'Start Task' below and do as instructed.
                
                \(details.instructions)
                """)
                    .multilineTextAlignment(.center)
                    .padding()
                    StartTaskButton(isDoingTask: $isDoingTask)
                }
                else {
                    if !showTaskContent {
                        GetReady(currentPage: $currentPage){
                            showTaskContent = true
                            showOrHideGlobe(true)
                            startTimer()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                if currentPage == .positionExperiment1 || currentPage == .positionExperiment2 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        let counterPosition = model.firstGlobeEntity?.repositionGlobe()
                                        model.secondGlobeEntity?.respawnGlobe(counterPosition ?? .center)
                                    }
                                }
                                if currentPage == .rotationExperiment1 || currentPage == .rotationExperiment2 {
                                    model.firstGlobeEntity?.rerotateGlobe()
                                    model.firstGlobeEntity?.respawnGlobe(.left)
                                    model.secondGlobeEntity?.respawnGlobe(.right)
                                }
                                if currentPage == .scaleExperiment1 || currentPage == .scaleExperiment2 {
                                    model.firstGlobeEntity?.rescaleGlobe()
                                    model.firstGlobeEntity?.respawnGlobe(.leftClose)
                                    model.secondGlobeEntity?.respawnGlobe(.rightClose)                                }
                            }
                            // Task{
//                                await checkMatchingStatus(taskNumber : details.taskNumber, model: model)
//                            }
//                            model.firstGlobeEntity?.respawnGlobe("Left")
//                            model.secondGlobeEntity?.respawnGlobe("Right")
                        }
                    } else {
                        if let currentTask = studyModel.currentTask, currentTask.isMatching{
//                        if studyModel.getMatcher(taskNumber: details.taskNumber, model: model) {
                            Text("Matched!")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding()
                        }
//                        Text("Time elapsed: \(String(format: "%.2f", elapsedTime)) seconds")
//                            .font(.title)
//                            .monospacedDigit()
//                            .padding()
                        //Below is for debugging only
                        VStack{
                            Text("Debugging:")
                            Text("currentPge: \(currentPage)")
                            Text("Is storing needed \(currentPage.isStoringRecordNeeded)")
                            Text("Current page: \(currentPage)")
                            //                        Text("current task accuracy: \(studyModel.currentTask? ?? 0.0)")
                            Text("is matching: \(studyModel.currentTask?.isMatching ?? false)")
                            Text("Last used index: \(PositionCondition.lastUsedPositionConditionIndex)")
                            Text("Is conditions looping complete: \(PositionCondition.positionConditionsCompleted)")
                        }
                        .padding()

                        
                        Instruction(currentPage: $currentPage)
                        if studyModel.proceedToNextExperiment {
                            Button(
                                "Finish \(details.description), and move to the next task."
                            ) {
                                studyModel.proceedToNextExperiment = false
                                PositionCondition.positionConditionsCompleted = false
                                ScaleCondition.scaleConditionsCompleted = false
                                RotationCondition.rotationConditionsCompleted = false
                                //                            studyModel.currentTaskPage = currentPage
                                isDoingTask = false
                                showTaskContent = false
                                showOrHideGlobe(false)
                                stopTimer()
                                switch currentPage {
                                case .positionExperiment1, .positionExperiment2:
                                    print("Entered positionExperiment case")
                                    do {
                                        try PositionCondition.savePositionConditions(positionConditions: model.positionConditions)
                                    } catch {
                                        print("Failed to save position conditions: \(error.localizedDescription)")
                                    }
                                case .rotationExperiment1, .rotationExperiment2:
                                    do {
                                        try RotationCondition.saveRotationConditions(rotationConditions: model.rotationConditions)
                                    } catch {
                                        print("Failed to save rotation conditions: \(error.localizedDescription)")
                                    }
                                case .scaleExperiment1, .scaleExperiment2:
                                    do {
                                        try ScaleCondition.saveScaleConditions(scaleConditions: model.scaleConditions)
                                    } catch {
                                        print("Failed to save position conditions: \(error.localizedDescription)")
                                    }
                                default:
                                    break
                                }
                                model.closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)
                                currentPage = currentPage.next()
                            }
                            .onAppear{
                                showOrHideGlobe(false)
                            }
                            .padding()
                            .background(Color.cyan)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                    }
                }
            } else {
                Text("Invalid Task")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray2)).shadow(radius: 5)).padding(40)
        .onAppear{
            updateAttachmentView()
            showOrHideGlobe(false)
//            model.closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)
        }
        .onDisappear{
            showOrHideGlobe(false)
//            model.closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)

        }
        .background(RoundedRectangle(cornerRadius: 15)
        .fill(Color(.systemGray4))
        .shadow(radius: 5))
        .padding(40)
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
        elapsedTime = 0
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
                model.hideGlobe(dismissImmersiveSpaceAction: dismissImmersiveSpaceAction)
            }
        }
    }
}

//#Preview {
//    TaskView(currentPage: .constant(.positionExperiment2))
//        .environment(ViewModel())
//        .environment(StudyModel())
//}
