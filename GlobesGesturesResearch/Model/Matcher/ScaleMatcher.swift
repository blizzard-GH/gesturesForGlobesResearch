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
    
    init(targetScale: SIMD3<Float>) {
        self.targetScale = targetScale
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let scaleDifference = simd_distance(transform.scale, targetScale)
        return scaleDifference <= tolerance
    }
    
    func getAccuracy(_ transform: Transform) -> Float {
        let scaleDifference = simd_distance(transform.scale, targetScale)
        return scaleDifference
    }
}
