//
//  ScaleTask.swift
//  SimpleGlobe
//
//

import Foundation

class ScaleTask: StudyTask {
    let taskID = UUID()
    var actions = ThrottledArray<StudyAction>(throttleInterval: ScaleTask.throttleInterval)
    var accuracyResult: Float = 0.0
    
    var matcher: any Matcher
    var soundManager: SoundManager

    
    init(originalScale: Float, targetScale: Float, soundManager: SoundManager) {
        self.matcher = ScaleMatcher(targetScale: SIMD3<Float>(repeating: targetScale), soundManager: soundManager)
        self.soundManager = soundManager
    }
    
    func saveToFile() {
        TaskStorageManager.shared.saveTask(self, type: .scale)
    }
    
    func updateAccuracyResult() {
        guard let lastTransform = actions.last?.originalTransform else {
            Log.error("No last transform recorded.")
            return
        }
        let accuracy = matcher.getAccuracy(lastTransform)
        accuracyResult = accuracy
        Log.info("Updated accuracy result: \(accuracyResult)")
    }
}
