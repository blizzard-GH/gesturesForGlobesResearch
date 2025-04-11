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
    @Environment(\.dismissWindow) private var dismissWindow
           
    var body: some View {
        VStack {
            if let details = studyModel.currentPage.taskDetails {
                Text("Part \(details.partNumber): \(details.mainGerund.capitalized) Experiment \(details.taskNumber)")
                    .font(.largeTitle)
                
                Text("Press the button when you are ready.")
                    .padding()
                
                Button(action: {
                    Task {
                        await model.load(firstGlobe: model.globe, secondGlobe: model.secondGlobe, openImmersiveSpaceAction: openImmersiveSpaceAction)
                        initializeGlobes()
                        dismissWindow(id: ViewModel.windowID)
                    }
                }) {
                    Label("Start Experiment", systemImage: "globe")
                }
                .tint(.accentColor)
                .padding()
            } else {
                Text("Invalid Task")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private func initializeGlobes() {
        switch studyModel.currentPage {
        case .positionExperiment1, .positionExperiment2:
            let counterPosition = model.firstGlobeEntity?.repositionGlobe()
            PositionCondition.positionConditionsSetter(for: ViewModel.shared.positionConditions,
                                                       lastUsedIndex: &PositionCondition.lastUsedPositionConditionIndex)
            model.secondGlobeEntity?.refineGlobePosition(counterPosition ?? SIMD3<Float>(0,0.9,-0.5))
        case .rotationExperiment1, .rotationExperiment2:
            model.firstGlobeEntity?.respawnGlobe(.leftClose)
            model.secondGlobeEntity?.respawnGlobe(.rightClose)
            let counterRotation = model.firstGlobeEntity?.rerotateGlobe()
            model.secondGlobeEntity?.animateTransform(orientation: counterRotation, duration: 0.2)
            RotationCondition.rotationConditionsSetter(for: ViewModel.shared.rotationConditions,
                                                       lastUsedIndex: &RotationCondition.lastUsedRotationConditionIndex)
        case .scaleExperiment1, .scaleExperiment2:
            model.firstGlobeEntity?.respawnGlobe(.leftClose)
            model.secondGlobeEntity?.respawnGlobe(.rightClose)
            let counterScale = model.firstGlobeEntity?.rescaleGlobe()
            model.secondGlobeEntity?.animateTransform(scale: counterScale, duration: 0.2)
            ScaleCondition.scaleConditionsSetter(for: ViewModel.shared.scaleConditions,
                                                 lastUsedIndex: &ScaleCondition.lastUsedScaleConditionIndex)
        default:
            break
        }
    }
}

#Preview {
    TaskView()
        .padding()
        .glassBackgroundEffect()
        .environment(ViewModel())
        .environment(StudyModel())
}
