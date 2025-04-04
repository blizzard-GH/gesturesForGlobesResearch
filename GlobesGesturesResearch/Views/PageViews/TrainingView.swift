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
        case .positionComparison:
            model.attachmentView = .position
        case .rotationComparison:
            model.attachmentView = .rotation
        case .scaleComparison:
            model.attachmentView = .scale
        default:
            model.attachmentView = .none
        }
    }
    
    var body: some View {
        VStack {
            if loadingInformation {
                ProgressView("Loading...")
                    .font(.headline)
                    .padding()
            } else {
                let details = currentPage.trainingDetails
                Text(" Training for \(details.trainingType).")
                    .font(.title)
                    .padding()
                
                Text("Learn how to \(details.gestureMethod) the globe.")
                    .font(.headline)
                    .padding()
                
                NextPageButton(page: $currentPage, title: "Finish Training")
                    .padding()
                
                Spacer().frame(height: 50)
            }
        }
        .onAppear{
            loadingInformation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                updateAttachmentView()
                showOrHideGlobe(true)
                loadingInformation = false
            }
        }
        .onDisappear{
            showOrHideGlobe(false)
        }
        .frame(minWidth: 800)
        .padding()
    }
    
    
    @MainActor
    private func showOrHideGlobe(_ show: Bool) {
        Task { @MainActor in
            if show {
                guard !model.configuration.isVisible else { return }
                model.loadSingleGlobe(
                    firstGlobe: model.globe,
                    openImmersiveSpaceAction: openImmersiveSpaceAction
                )
            } else {
                guard model.configuration.isVisible else { return }
                model.hideGlobe(dismissImmersiveSpaceAction: dismissImmersiveSpaceAction)
            }
        }
    }
}


#Preview {
    TrainingView(currentPage: .constant(.positionTraining))
        .glassBackgroundEffect()
        .environment(ViewModel())
        .environment(StudyModel())
}
