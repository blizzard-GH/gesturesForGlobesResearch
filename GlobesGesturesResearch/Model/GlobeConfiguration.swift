//
//  GlobeConfiguration.swift
//  Globes
//
//  Created by Bernhard Jenny on 14/3/2024.
//

import SwiftUI

/// Configuration information for globe entities.
@MainActor
struct GlobeConfiguration: Equatable {
    
    // The globe for this configuration
    let globe: Globe
    
    // MARK: - Size
    
    /// Maximum diameter of globe when scaled up in meter
    static let maxDiameter: Float = 5
    
    /// Minimum diameter of globe when scaled down in meter
    static let minDiameter: Float = 0.05
        
    // MARK: - Position
    
    /// Position the globe relative to the camera location such that the closest point on the globe is at `distanceToGlobe`.
    /// The direction between the camera and the globe is 30 degrees below the horizon.
    /// - Parameter distanceToGlobe: Distance to globe
    func positionRelativeToCamera(distanceToGlobe: Float, xOffset: Float = 0) -> SIMD3<Float> {
        guard let cameraViewDirection = CameraTracker.shared.viewDirection,
              let cameraPosition = CameraTracker.shared.position else {
            return SIMD3(0, 1, 0)
        }
        
        // oblique distance between camera and globe center
        let d = (globe.radius + distanceToGlobe)
        
        // position relative to camera position
        var position = cameraViewDirection * d + cameraPosition

        // vertically shift the globe down
        // the center of the globe is at this angle below the horizon
        let alpha: Float = 30 / 180 * .pi
        position.y -= sin(alpha) * d
        position.x = xOffset
        
        return position
    }
    
    // MARK: - Scale
            
    /// Minimum scale factor
    var minScale: Float {
        let d = 2 * globe.radius
        return Self.minDiameter / d
    }
    
    /// Maximum scale factor
    var maxScale: Float {
        let d = 2 * globe.radius
        return max(1, Self.maxDiameter / d)
    }
    
    // MARK: - Rotation
    
    /// Speed of rotation used
    var rotationSpeed: Float
    
    /// Duration in seconds for full rotation of a spinning globe with a radius of 1 meter.
    static private let rotationDuration: Float = 120
    
    /// Angular speed in radians per second for a spinning globe with a radius of 1 meter.
    /// Globes with a smaller radius rotate faster, and globes with a larger radius rotate slower.
    /// Globes with a scale factor greater than 1 rotate slower, and globes with a scale factor smaller than 1 rotate faster.
    static let defaultRotationSpeed: Float = 2 * .pi / rotationDuration
    
    /// Angular speed in radians per second for a small preview globe.
    static let defaultRotationSpeedForPreviewGlobes: Float = 2 * .pi / 24
    
    /// Pause rotation by `RotationSystem`
    var isRotationPaused: Bool
    
    /// Current speed of rotation taking `isRotationPaused` flag into account.
    var currentRotationSpeed: Float {
        isRotationPaused ? 0 : rotationSpeed
    }
    
    // MARK: - Initializer
    
    init(
        globe: Globe,
        speed: Float = 0,
        isRotationPaused: Bool = false
    ) {
        self.globe = globe
        self.rotationSpeed = speed
        self.isRotationPaused = isRotationPaused
    }
}
