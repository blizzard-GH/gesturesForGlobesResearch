//
//  RotationMatcher.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 8/1/2025.
//

import Foundation
import RealityKit

@Observable
class RotationMatcher: Matcher {
    let rotationTarget: simd_quatf
    let tolerance: Float = 15 * .pi / 180
        
    init(rotationTarget: simd_quatf) {
        self.rotationTarget = rotationTarget
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let angleDifference = quaternionAngleDifference(q1: transform.rotation, q2: rotationTarget)
        return angleDifference <= tolerance
    }
    
    func accuracy(of transform: Transform) -> Float {
        quaternionAngleDifference(q1: transform.rotation, q2: rotationTarget)
    }
    
    private func quaternionAngleDifference(q1: simd_quatf, q2: simd_quatf) -> Float {
        let q1 = simd_normalize(q1)
        let q2 = simd_normalize(q2)
        
        // Compute the dot product and clamp to avoid numerical issues
        let dotProduct = simd_dot(q1, q2)
        let clampedDot = max(-1.0, min(1.0, dotProduct))
        let angle = 2 * acos(clampedDot)
       
        return angle
    }
}
