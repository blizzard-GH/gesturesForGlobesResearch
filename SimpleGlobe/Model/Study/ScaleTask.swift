//
//  ScaleTask.swift
//  SimpleGlobe
//
//

import Foundation

class ScaleTask: StudyTask {
    var matcher: any Matcher
    var actions: [StudyAction] = []
    var accuracyResult: Int = 0
    
    init(targetScale: Float) {
        matcher = ScaleMatcher(targetScale: SIMD3<Float>(repeating: targetScale))
    }
    
    func toCodable() -> ScaleTaskCodable {
        return ScaleTaskCodable(actions: self.actions, accuracyResult: self.accuracyResult)
    }
    
    func saveToFile() {
        let codableTask = toCodable()
        TaskStorageManager.shared.saveTask(codableTask, type: .position)
    }
}
