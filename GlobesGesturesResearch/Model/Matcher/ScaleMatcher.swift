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
    let targetScale: Float
    let tolerance: Float = 0.1
        
    init(targetScale: Float) {
        self.targetScale = targetScale
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let relativeDifference = accuracy(of: transform)
        return relativeDifference <= tolerance
    }
    
    func accuracy(of transform: Transform) -> Float {
        let scaleRatio = transform.scale.max() / targetScale
        let relativeDifference = abs(scaleRatio - 1)
        return relativeDifference
    }
}
