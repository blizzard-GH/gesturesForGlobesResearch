//
//  Untitled.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 25/3/2025.
//

import SwiftUI

struct ConfirmationPage: View {
    @Environment(ViewModel.self) var model
    @Environment(StudyModel.self) var studyModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    
    @Binding var currentPage: Page
    @State private var isDoingTask: Bool = false
    @State private var elapsedTime: Double = 0
    @State private var timer: Timer? = nil
    @State private var startTime: Date? = nil
    @State private var showTaskContent: Bool = false
    
    var body: some View {
        VStack{
            if let details = currentPage.taskDetails {
                Text("Part \(details.partNumber): task \(details.taskNumber) finished")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            Button(
                "Next"
            ) {
                studyModel.proceedToNextExperiment = false
                PositionCondition.positionConditionsCompleted = false
                ScaleCondition.scaleConditionsCompleted = false
                RotationCondition.rotationConditionsCompleted = false
                //                            studyModel.currentTaskPage = currentPage
//                if currentPage == .rotationExperiment1 || currentPage == .rotationExperiment2{
////                    RotationCondition.rotationSwapTechnique.toggle()
//                    updateRotationConditions()
//                }
                isDoingTask = false
                showTaskContent = false
                showOrHideGlobe(false)
                switch currentPage {
                case
//                        .positionExperiment1,
                        .positionExperiment2:
                    print("Entered positionExperiment case")
                    do {
                        try PositionCondition.savePositionConditions(positionConditions: model.positionConditions)
                    } catch {
                        print("Failed to save position conditions: \(error.localizedDescription)")
                    }
                
                case
//                        .rotationExperiment1,
                        .rotationExperiment2:
                    do {
                        try RotationCondition.saveRotationConditions(rotationConditions: model.rotationConditions)
                    } catch {
                        print("Failed to save rotation conditions: \(error.localizedDescription)")
                    }
                case
//                        .scaleExperiment1,
                        .scaleExperiment2:
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
//                print("GESTURE FEATURE COMPLETED: \(RotationCondition.gestureFeatureCompleted)")
              
            }
            .onAppear{
                showOrHideGlobe(false)
            }
            .bold()
            .padding()
            .background(Color.cyan)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray2)).shadow(radius: 5)).padding(40)
        .onAppear{
            isDoingTask = false
            showTaskContent = false
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
        .frame(minWidth: 800, minHeight: 800)
    }
    
    private func updateAttachmentView() {
            switch currentPage {
            case .positionComparison:
                model.attachmentView = .position
            case .rotationComparison:
                model.attachmentView = .rotation
            case .scaleComparison:
                model.attachmentView = .scale
            case .outroForm:
                model.attachmentView = .all
            default:
                model.attachmentView = .none
            }
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
    
//    Switching between one-handed or two-handed rotation
//    func updateRotationConditions() {
//        model.updateRotationConditions()
//    }
}
