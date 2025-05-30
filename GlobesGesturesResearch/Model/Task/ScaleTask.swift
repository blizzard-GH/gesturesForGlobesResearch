//
//  ScaleTask.swift
//  SimpleGlobe
//
//

import Foundation

class ScaleTask: StudyTask {
    let actionID = UUID()
    var actions = ThrottledArray<StudyAction>(throttleInterval: ScaleTask.throttleInterval)
    var accuracyResult: Float = 0.0    
    let matcher: any Matcher

    init(targetScale: Float) {
        self.matcher = ScaleMatcher(targetScale: targetScale)
    }
    
    func saveToFile() {
        TaskStorageManager.shared.saveTask(self, type: .scale)
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
