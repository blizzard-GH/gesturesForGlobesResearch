//
//  TrainingView.swift
//  GlobesGesturesResearch
//
//  Created by Faisal Agung Abdillah on 11/2/2025.
//

import SwiftUI

struct TrainingView: View {
    @Environment(ViewModel.self) var model
    @Environment(StudyModel.self) var studyModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpaceAction
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction

    @State var loadingInformation: Bool = false
    
    @Binding var currentPage: Page

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
            if loadingInformation {
                ProgressView("Loading...") // Show loading indicator
                    .font(.headline)
                    .padding()
            } else {
                let details = currentPage.trainingDetails
                Text(" This is the training session for \(details.trainingType).")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("""
                In this section we are making sure you are familiar with \(details.gestureMethod). 
                
                \(details.trainingDescription).
                
                If you have done, click the button to continue to the study.
                """)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                
                Button(
                    "Finish training, and move to the next task."
                ) {
                    currentPage = currentPage.next()
                    //                studyModel.currentTaskPage = currentPage
                }
                Text("immersiveSpaceIsShown : \(model.immersiveSpaceIsShown)")
                Text("model.config.isVisible : \(model.configuration.isVisible)")
            }
        }
        .onAppear{
            loadingInformation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                updateAttachmentView()
                showOrHideGlobe(true)
                //            model.closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)
                loadingInformation = false
            }
        }
        .onDisappear{
            showOrHideGlobe(false)
//            model.closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)
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
}
