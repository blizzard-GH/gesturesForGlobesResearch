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
        
    var body: some View {
        VStack{
            Text("Experiment Finished")
                .font(.largeTitle)
                .padding()
            Text("Please fill out the questionnaire in the next section.")
                .font(.subheadline)
                .padding()
            Button("Next", action: next)
                .padding()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color(.systemGray4))
            .shadow(radius: 5))
        .padding(40)
        .frame(minWidth: 800, minHeight: 800)
    }
    
    private func next() {
        PositionCondition.positionConditionsCompleted = false
        ScaleCondition.scaleConditionsCompleted = false
        RotationCondition.rotationConditionsCompleted = false
        switch studyModel.currentPage {
        case .confirmationPagePosition2:
            do {
                try PositionCondition.savePositionConditions(positionConditions: model.positionConditions)
            } catch let err {
                model.errorToShowInAlert = error("Failed to save position conditions: \(err.localizedDescription)")
            }
        case .confirmationPageRotation2:
            do {
                try RotationCondition.saveRotationConditions(rotationConditions: model.rotationConditions)
            } catch let err {
                model.errorToShowInAlert = error("Failed to save rotation conditions: \(err.localizedDescription)")
            }
        case .confirmationPageScale2:
            do {
                try ScaleCondition.saveScaleConditions(scaleConditions: model.scaleConditions)
            } catch let err {
                model.errorToShowInAlert = error("Failed to save position conditions: \(err.localizedDescription)")
            }
        default:
            break
        }
        studyModel.currentPage = studyModel.currentPage.next()
    }
}
