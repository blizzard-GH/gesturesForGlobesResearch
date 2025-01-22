//
//  PositionTask.swift
//  SimpleGlobe
//
//

import Foundation

@MainActor
class PositionTask: StudyTask {
    var actions: [StudyAction] = []
    var accuracyResult: Int = 0
    
    var matcher: any Matcher
    
    init(targetPosition: SIMD3<Float>) {
        self.matcher = PositionMatcher(targetPosition: targetPosition)
    }
    
    func toCodable() -> PositionTaskCodable {
        return PositionTaskCodable(actions: self.actions, accuracyResult: self.accuracyResult)
    }
    
    func saveToFile() {
        let codableTask = toCodable()
        TaskStorageManager.shared.saveTask(codableTask, type: .position)
    }
}
