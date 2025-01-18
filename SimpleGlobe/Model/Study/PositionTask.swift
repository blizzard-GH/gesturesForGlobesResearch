//
//  PositionTask.swift
//  SimpleGlobe
//
//

import Foundation

@MainActor
class PositionTask: StudyTask {
    var matcher: any Matcher
    
    init(targetPosition: SIMD3<Float>) {
        self.matcher = PositionMatcher(targetPosition: targetPosition)
    }
    
    var actions: [StudyAction] = []
    var accuracyResult: Int = 0
}
