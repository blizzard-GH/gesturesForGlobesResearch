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
    let targetTransform: Transform
    
    let tolerance: Float = 15 * .pi / 180

    init(targetTransform: Transform) {
        self.targetTransform = targetTransform
    }
    
    func isMatching(_ transform: Transform) -> Bool {
        let angleDifference = try? apparentAngularDifference(transform1: transform, transform2: targetTransform)
        return angleDifference ?? .infinity <= tolerance
    }
    
    func accuracy(of transform: Transform) -> Float {
        let accuracy = try? apparentAngularDifference(transform1: transform, transform2: targetTransform)
        return accuracy ?? .infinity
    }

    /// The angular difference between two transforms compensated for the direction of view.
    /// - Parameters:
    ///   - transform1: First transform
    ///   - transform2: Second transform
    /// - Returns: Angle in radians
    private func apparentAngularDifference(transform1: Transform, transform2: Transform) throws -> Float {
//        let uncompensatedAngle = angleBetweenQuaternions(q1: transform1.rotation, q2: transform2.rotation)
//        print("uncompensated", uncompensatedAngle / .pi * 180)
        
        let q1 = try Self.apparentRotation(transform: transform1)
        let q2 = try Self.apparentRotation(transform: transform2)
        let angle = angleBetweenQuaternions(q1: q1, q2: q2)
//        print("compensated", angle / .pi * 180)
        return angle
    }
    
    /// Computes a rotation to compensate for the direction of view.
    /// - Parameter transform: Transform with rotation and position.
    /// - Returns: Rotation quaternion.
    static private func apparentRotation(transform: Transform) throws -> simd_quatf {
        guard let cameraPosition = CameraTracker.shared.position else {
            throw error("Camera position undefined")
        }
        
        // unary direction from the globe to the camera
        let d = simd_normalize(cameraPosition - transform.translation)
        
        // unary direction from the globe to the camera projected onto the y-z plane
        let dyz = simd_normalize(SIMD3(0, d.y, d.z))
        
        // rotation from dyz to d
        let correction = simd_quatf(from: d, to: dyz)
        let rotation = simd_normalize(transform.rotation)
        return correction * rotation
    }
    
    /// The angle between two quaternions in radians between 0 and π.
    /// https://math.stackexchange.com/a/90098
    /// - Parameters:
    ///   - q1: Quaternion one
    ///   - q2: Quaternion two
    /// - Returns: Angle in radians
    private func angleBetweenQuaternions(q1: simd_quatf, q2: simd_quatf) -> Float {
        let q1 = simd_normalize(q1)
        let q2 = simd_normalize(q2)
        let angle = 2 * acos(abs(simd_dot(q1, q2)))
//        print(angle / .pi * 180)
        return angle
    }
}
