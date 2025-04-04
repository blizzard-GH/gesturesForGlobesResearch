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
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction
    
    @Binding var currentPage: Page
    
    var body: some View {
        VStack{
            Text("Task finished")
                .font(.largeTitle)
                .padding()
            Button("Next", action: next)
                .padding()
        }
        .padding()
        .onAppear{
            model.updateAttachmentView(for: currentPage)
            hideGlobe()
        }
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemGray4))
            .shadow(radius: 5))
        .padding(40)
        .frame(minWidth: 800, minHeight: 800)
    }
    
    private func next() {
        studyModel.proceedToNextExperiment = false
        PositionCondition.positionConditionsCompleted = false
        ScaleCondition.scaleConditionsCompleted = false
        RotationCondition.rotationConditionsCompleted = false
        switch currentPage {
        case .confirmationPagePosition2:
            do {
                try PositionCondition.savePositionConditions(positionConditions: model.positionConditions)
            } catch {
                print("Failed to save position conditions: \(error.localizedDescription)")
            }
            
        case .confirmationPageRotation2:
            do {
                try RotationCondition.saveRotationConditions(rotationConditions: model.rotationConditions)
            } catch {
                print("Failed to save rotation conditions: \(error.localizedDescription)")
            }
        case .confirmationPageScale2:
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
    
    private func hideGlobe() {
        Task { @MainActor in
            guard model.configuration.isVisible else { return }
            model.hideGlobes(dismissImmersiveSpaceAction: dismissImmersiveSpaceAction)
        }
    }
}
