//
//  PositionMatcher.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 18/12/2024.
//

import Foundation
import RealityKit

class PositionMatcher: ObservableObject {
    @Published var isPositionMatched: Bool = false
    
    private var timer: Timer? = nil
    
//    func checkPositionMatched() -> Bool {
//        return isPositionMatched
//    }
    
    @MainActor
    func checkPosition(model: ViewModel, tolerance: Float = 2) {
        guard let first = model.globeEntity?.position(relativeTo: nil),
              let second = model.secondGlobeEntity?.position(relativeTo: nil) else {
            isPositionMatched = false
            return
        }
        
        let distance = simd_distance(first, second)
        
        if distance <= tolerance {
            isPositionMatched = true
        } else {
            isPositionMatched = false
        }
    }
}
