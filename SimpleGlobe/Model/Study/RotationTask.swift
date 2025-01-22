//
//  RotationTask.swift
//  SimpleGlobe
//
//

import Foundation
import RealityKit

class RotationTask: StudyTask {
    var actions = ThrottledArray<StudyAction>(throttleInterval: RotationTask.throttleInterval)
    var accuracyResult: Int = 0
    
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
}
