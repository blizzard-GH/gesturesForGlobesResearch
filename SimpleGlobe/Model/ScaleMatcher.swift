//
//  ScaleMatcher.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 8/1/2025.
//

import Foundation
import RealityKit

@Observable
class ScaleMatcher {
    var isScaleMatched: Bool = false
    
    @ObservationIgnored private var timer: Timer? = nil
    
    @MainActor
    func checkScale(model: ViewModel, tolerance: Float = 0.5) -> Bool{
        guard let first = model.globeEntity?.scale(relativeTo: nil),
              let second = model.secondGlobeEntity?.scale(relativeTo: nil) else {
            isScaleMatched = false
            return false
        }
        
        let size_difference = simd_distance(first, second)
        
        if size_difference <= tolerance {
            isScaleMatched = true
            return true
        } else {
            isScaleMatched = false
            return false
        }
    }
}
