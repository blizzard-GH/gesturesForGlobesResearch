//
//  RotationTask.swift
//  SimpleGlobe
//
//

import Foundation
import RealityKit

class RotationTask: StudyTask {
    var actions: [StudyAction] = []
    var matcher: any Matcher

    var accuracyResult: Int = 0
    
    init(targetRotation: simd_quatf) {
        matcher = RotationMatcher(rotationTarget: targetRotation)
    }
    
    func toCodable() -> RotationTaskCodable {
        return RotationTaskCodable(actions: self.actions, accuracyResult: self.accuracyResult)
    }
    
    func saveToFile() {
        let codableTask = toCodable()
        TaskStorageManager.shared.saveTask(codableTask, type: .rotation)
    }
}
