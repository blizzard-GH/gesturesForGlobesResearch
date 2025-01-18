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
    let tolerance: Float = 0.5
    
    init(rotationTarget: simd_quatf) {
        self.rotationTarget = rotationTarget
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let angleDifference = quaternionAngleDifference(q1: transform.rotation, q2: rotationTarget)
        return angleDifference <= tolerance
    }
    
    func quaternionAngleDifference(q1: simd_quatf, q2: simd_quatf) -> Float {
        // Calculate the dot product of the two quaternions and make it absolute
        var dotProduct = simd_dot(q1.vector, q2.vector)
        
        if dotProduct < 0 {
            dotProduct = -dotProduct
        }
        
        // Avoiding numerical errors
        let clampedDot = max(-1.0, min(1.0, dotProduct))
        
        // Measure the angle between the two quaternions
        let angle = 2.0 * acos(clampedDot)
        
        return angle
    }
}
