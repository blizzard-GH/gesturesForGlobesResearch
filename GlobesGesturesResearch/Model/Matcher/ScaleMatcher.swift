//
//  ScaleMatcher.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 8/1/2025.
//

import Foundation
import RealityKit

@Observable
class ScaleMatcher: Matcher {
    let targetScale: SIMD3<Float>
    let tolerance: Float = 0.5
    
    private let soundManager: SoundManager
    
    init(targetScale: SIMD3<Float>, soundManager: SoundManager) {
        self.targetScale = targetScale
        self.soundManager = soundManager
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let scaleDifference = simd_distance(transform.scale, targetScale)
        let matched = scaleDifference <= tolerance

        return matched
    }
    
    func getAccuracy(_ transform: Transform) -> Float {
        let scaleDifference = simd_distance(transform.scale, targetScale)
        return scaleDifference
    }
}
