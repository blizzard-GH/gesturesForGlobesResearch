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
    let tolerance: Float = 0.05
    
    init(targetPosition: SIMD3<Float>) {
        self.targetPosition = targetPosition
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let distance = accuracy(of: transform)
        return distance <= tolerance
    }
    
    func accuracy(of transform: Transform) -> Float {
        simd_distance(transform.translation, targetPosition)
    }
}
