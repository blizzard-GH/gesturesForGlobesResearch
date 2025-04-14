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
    let tolerance: Float = 10 * .pi * 180
        
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
        let normQ1 = simd_normalize(q1)
        let normQ2 = simd_normalize(q2)
        let v1 = q1.act([0, 1, 0])
        let v2 = q2.act([0, 1, 0])
        let angle = acos(simd_dot(v1, v2))
        return angle
    }
}
