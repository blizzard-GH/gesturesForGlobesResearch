//
//  RotationTask.swift
//  SimpleGlobe
//
//

import Foundation
import RealityKit

class RotationTask: StudyTask {
    var actions: [StudyAction] = []
    var matcher: any Matcher

    var accuracyResult: Int = 0
    
    init(targetRotation: simd_quatf) {
        matcher = RotationMatcher(rotationTarget: targetRotation)
    }
}
