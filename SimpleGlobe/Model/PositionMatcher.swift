//
//  PositionMatcher.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 18/12/2024.
//

import Foundation
import RealityKit
import simd

@Observable
class PositionMatcher {
    var isPositionMatched: Bool = false
    
    private var timer: Timer? = nil
    
    @MainActor
    func checkPosition(model: ViewModel, tolerance: Float = 0.5) -> Bool {
        guard let first = model.globeEntity?.position(relativeTo: nil),
              let second = model.secondGlobeEntity?.position(relativeTo: nil) else {
            isPositionMatched = false
            return false
        }
        
        let distance = simd_distance(first, second)
        
        if distance <= tolerance {
            isPositionMatched = true
            return true
        } else {
            isPositionMatched = false
            return false
        }
    }
}
