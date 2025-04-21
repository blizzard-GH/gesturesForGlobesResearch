//
//  RotationTask.swift
//  SimpleGlobe
//
//

import Foundation
import RealityKit

class RotationTask: StudyTask {
    let actionID = UUID()
    var actions = ThrottledArray<StudyAction>(throttleInterval: RotationTask.throttleInterval)
    var accuracyResult: Float = 0.0
    
    let matcher: any Matcher

    init(targetTransform: Transform) {
        self.matcher = RotationMatcher(targetTransform: targetTransform)
    }    
    
    func saveToFile() {
        TaskStorageManager.shared.saveTask(self, type: .rotation)
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
