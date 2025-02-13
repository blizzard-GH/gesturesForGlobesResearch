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
            Text("""
            This is the training session.
            """)
            .font(.title)
            .multilineTextAlignment(.center)
            .padding()
            Text("""
                Before we begin the study, please make yourself familiar with the gestures for globes. 
                Two globes will appear, and they are fully interactible.
                Please feel free to move the main globe around while practising the gesture.
                You can also try to move the globe to match the target globe (the one with less opacity)
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
            
        }
        .onAppear{
            updateAttachmentView()
            showOrHideGlobe(true)
        }
        .onDisappear{
            showOrHideGlobe(false)
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
                model.hideGlobe()
            }
        }
    }
}
