//
//  PositionTask.swift
//  SimpleGlobe
//
//

import Foundation

@MainActor
class PositionTask: StudyTask {
    let actionID = UUID()
    var actions = ThrottledArray<StudyAction>(throttleInterval: PositionTask.throttleInterval)
    var accuracyResult: Float = 0.0
    let matcher: any Matcher

    init(targetPosition: SIMD3<Float>) {
        self.matcher = PositionMatcher(targetPosition: targetPosition)
    }
    
    func saveToFile() {
        TaskStorageManager.shared.saveTask(self, type: .position)
    }
    
    func updateAccuracyResult() {
        guard let lastTransform = actions.last?.originalTransform else {
            Log.error("No last transform recorded.")
            return
        }
        let accuracy = matcher.accuracy(of: lastTransform)
        accuracyResult = accuracy
        Log.info("Updated accuracy result: \(accuracyResult)")
    }
}
