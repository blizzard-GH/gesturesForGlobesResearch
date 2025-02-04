//
//  PositionTask.swift
//  SimpleGlobe
//
//

import Foundation

@MainActor
class PositionTask: StudyTask {
    let taskID = UUID()
    var actions = ThrottledArray<StudyAction>(throttleInterval: PositionTask.throttleInterval)
    var accuracyResult: Float = 0.0
    
    var matcher: any Matcher
    
    init(originalPosition: SIMD3<Float>, targetPosition: SIMD3<Float>) {
        self.matcher = PositionMatcher(targetPosition: targetPosition)
    }
    
    func saveToFile() {
        TaskStorageManager.shared.saveTask(self, type: .position)
    }
    
    func updateAccuracyResult() {
        guard let lastTransform = actions.last?.targetTransform else {
            Log.error("No last transform recorded.")
            return
        }
        let accuracy = matcher.getAccuracy(lastTransform)
        accuracyResult = accuracy
        Log.info("Updated accuracy result: \(accuracyResult)")
    }
}
