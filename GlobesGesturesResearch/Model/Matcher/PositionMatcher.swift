//
//  PositionMatcher.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 18/12/2024.
//

import Foundation
import RealityKit
import simd

@MainActor
class PositionMatcher: Matcher {
    let targetPosition: SIMD3<Float>
    let tolerance: Float = 0.5
    private let soundManager: SoundManager

    
    init(targetPosition: SIMD3<Float>, soundManager: SoundManager) {
        self.targetPosition = targetPosition
        self.soundManager = soundManager
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let distance = simd_distance(transform.translation, targetPosition)
        let matched = distance <= tolerance

        return matched
    }
    
    func getAccuracy(_ transform: Transform) -> Float {
        let distance = simd_distance(transform.translation, targetPosition)
        return distance
    }
}
