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
                model.updateAttachmentView(for: currentPage)
                if !model.configuration.isVisible {
                    model.loadSingleGlobe(globe: model.globe, openImmersiveSpaceAction: openImmersiveSpaceAction)
                }
                loadingInformation = false
            }
        }
        .onDisappear{
            if model.configuration.isVisible {
                model.hideGlobes(dismissImmersiveSpaceAction: dismissImmersiveSpaceAction)
            }
        }
        .frame(minWidth: 800)
        .padding()
    }
}


#Preview {
    TrainingView(currentPage: .constant(.positionTraining))
        .glassBackgroundEffect()
        .environment(ViewModel())
        .environment(StudyModel())
}
