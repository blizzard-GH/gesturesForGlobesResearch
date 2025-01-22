//
//  PositionTask.swift
//  SimpleGlobe
//
//

import Foundation

@MainActor
class PositionTask: StudyTask {
    var actions = ThrottledArray<StudyAction>(throttleInterval: PositionTask.throttleInterval)
    var accuracyResult: Int = 0
    
    var matcher: any Matcher
    
    init(targetPosition: SIMD3<Float>) {
        self.matcher = PositionMatcher(targetPosition: targetPosition)
    }
    
    func toCodable() -> PositionTaskCodable {
        return PositionTaskCodable(actions: actions.elements, accuracyResult: accuracyResult)
    }
    
    func saveToFile() {
        let codableTask = toCodable()
        TaskStorageManager.shared.saveTask(codableTask, type: .position)
    }
}
