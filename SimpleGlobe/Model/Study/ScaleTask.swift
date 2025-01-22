//
//  ScaleTask.swift
//  SimpleGlobe
//
//

import Foundation

class ScaleTask: StudyTask {
    var actions = ThrottledArray<StudyAction>(throttleInterval: ScaleTask.throttleInterval)
    var accuracyResult: Float = 0.0
    
    var matcher: any Matcher
    
    init(targetScale: Float) {
        matcher = ScaleMatcher(targetScale: SIMD3<Float>(repeating: targetScale))
    }
    
    func toCodable() -> ScaleTaskCodable {
        return ScaleTaskCodable(actions: actions.elements, accuracyResult: accuracyResult)
    }
    
    func saveToFile() {
        let codableTask = toCodable()
        TaskStorageManager.shared.saveTask(codableTask, type: .scale)
    }
    
    func updateAccuracyResult() {
        guard let lastTransform = actions.last?.transform else {
            Log.error("No last transform recorded.")
            return
        }
        let accuracy = matcher.getAccuracy(lastTransform)
        accuracyResult = accuracy
        Log.info("Updated accuracy result: \(accuracyResult)")
    }
}
