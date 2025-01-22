//
//  RotationTask.swift
//  SimpleGlobe
//
//

import Foundation
import RealityKit

class RotationTask: StudyTask {
    var actions = ThrottledArray<StudyAction>(throttleInterval: RotationTask.throttleInterval)
    var accuracyResult: Float = 0.0
    
    var matcher: any Matcher
    
    init(targetRotation: simd_quatf) {
        matcher = RotationMatcher(rotationTarget: targetRotation)
    }
    
    func toCodable() -> RotationTaskCodable {
        return RotationTaskCodable(actions: actions.elements, accuracyResult: accuracyResult)
    }
    
    func saveToFile() {
        let codableTask = toCodable()
        TaskStorageManager.shared.saveTask(codableTask, type: .rotation)
    }
    
    func updateAccuracyResult() {
        guard let lastTransform = actions.last?.transform else {
            Log.error("No last transform recorded.")
            return
        }
        let accuracy = matcher.getAccuracy(lastTransform)
        accuracyResult = accuracy
        Log.info("Updated accuracy result: \(accuracyResult)")
    }
}
