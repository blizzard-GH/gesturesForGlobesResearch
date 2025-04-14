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
    let tolerance: Float = 0.175
        
    init(targetScale: SIMD3<Float>) {
        self.targetScale = targetScale
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let scaleRatio = transform.scale / targetScale
        let scaleDifferenceRelative = abs(scaleRatio - SIMD3<Float>(repeating: 1))
        
        let matched = all(scaleDifferenceRelative .<= SIMD3<Float>(repeating: tolerance))

        return matched
    }
    
    func getAccuracy(_ transform: Transform) -> Float {
        let scaleDifference = abs(transform.scale - targetScale)
//        return simd_length(scaleDifference) / simd_length(targetScale)
        return simd_length(scaleDifference)
        
    }
}
