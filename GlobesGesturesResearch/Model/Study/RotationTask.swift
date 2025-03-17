//
//  RotationTask.swift
//  SimpleGlobe
//
//

import Foundation
import RealityKit

class RotationTask: StudyTask {
    let taskID = UUID()
    var actions = ThrottledArray<StudyAction>(throttleInterval: RotationTask.throttleInterval)
    var accuracyResult: Float = 0.0
    
    var matcher: any Matcher
    var soundManager: SoundManager

    
    init(originalRotation: simd_quatf, targetRotation: simd_quatf, soundManager: SoundManager) {
        self.matcher = RotationMatcher(rotationTarget: targetRotation, soundManager: soundManager)
        self.soundManager = soundManager
    }
    
    
    func saveToFile() {
        TaskStorageManager.shared.saveTask(self, type: .rotation)
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
