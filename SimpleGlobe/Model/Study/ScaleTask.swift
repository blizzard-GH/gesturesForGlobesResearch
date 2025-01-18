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
}
