//
//  GlobeEntity.swift
//  Globes
//
//  Created by Bernhard Jenny on 13/3/2024.
//

import os
import RealityKit
import SwiftUI

/// Globe entity with a model child consisting of a mesh and a material, plus  `InputTargetComponent`, `CollisionComponent` and `PhysicsBodyComponent` components.
/// Gestures mutate the transform of this parent entity, while the optional automatic rotation mutates the transform of the child entity.
class GlobeEntity: Entity {
    
    /// Child model entity
    var modelEntity: Entity? { children.first(where: { $0 is ModelEntity }) }
    
    /// Small roughness results in shiny reflection, large roughness results in matte appearance
    let roughness: Float = 0.4
    
    /// Simulate clear transparent coating between 0 (none) and 1
    let clearcoat: Float = 0.05
    
    /// Duration of animations of scale, orientation and position in seconds.
    static let transformAnimationDuration: Double = 2
        
    /// Controller for stopping animated transformations.
    var animationPlaybackController: AnimationPlaybackController? = nil
    
    var positionConditions: [PositionCondition] {
        return ViewModel.shared.positionConditions
    }
    
    var rotationConditions: [RotationCondition] {
        return ViewModel.shared.rotationConditions
    }
    
    var scaleConditions: [ScaleCondition] {
        return ViewModel.shared.scaleConditions
    }
    
    var isInMovement: Bool = false
    
    var lastGlobeReposition: SIMD3<Float>?
    
    var lastGlobeCounterReposition: SIMD3<Float>?
        
    var useFirstRotationIndex: Bool = true
    
    var useFirstScaleIndex: Bool = true
    
    enum GlobePosition: CaseIterable {
        case center, left, leftClose, right, rightClose
        case centerUp, leftUp, rightUp, centerDown, leftDown, rightDown

        var position: SIMD3<Float> {
            switch self {
            case .center: return SIMD3(0, 0.9, -1.5)
            case .left: return SIMD3(-0.5, 0.9, -1.5)
            case .leftClose: return SIMD3(-0.4, 0.9, -1.5)
            case .right: return SIMD3(0.5, 0.9, -1.5)
            case .rightClose: return SIMD3(0.4, 0.9, -1.5)
            case .centerUp: return SIMD3(0, 1.6, -1.5)
            case .leftUp: return SIMD3(-0.5, 1.6, -1.5)
            case .rightUp: return SIMD3(0.5, 1.6, -1.5)
            case .centerDown: return SIMD3(0, 0.4, -1.5)
            case .leftDown: return SIMD3(-0.5, 0.4, -1.5)
            case .rightDown: return SIMD3(0.5, 0.4, -1.5)
            }
        }
    }
    
    @MainActor required init() {
        super.init()
    }
    
    /// Globe entity
    /// - Parameters:
    ///   - globe: Globe settings.
    init(globe: Globe) async throws {
        super.init()
        self.name = globe.name
        
        let material = try await ResourceLoader.loadMaterial(
            globe: globe,
            loadPreviewTexture: false,
            roughness: roughness,
            clearcoat: clearcoat
        )
        try Task.checkCancellation() // https://developer.apple.com/wwdc21/10134?time=723
        
        let mesh: MeshResource = .generateSphere(radius: globe.radius)
        let modelEntity = ModelEntity(mesh: mesh, materials: [material])
        modelEntity.name = "Sphere"
        modelEntity.components.set(GroundingShadowComponent(castsShadow: true))
        self.addChild(modelEntity)
        
        // Add InputTargetComponent to enable gestures
        components.set(InputTargetComponent())
        components.set(CollisionComponent(shapes: [.generateSphere(radius: globe.radius)]))
        
        // Set PhysicsBodyComponent to .kinematic to disable physical gestures
        components.set(PhysicsBodyComponent(
            shapes: [.generateSphere(radius: globe.radius)], // Use the existing collision shape
            mass: 0, // Mass is irrelevant for .kinematic
            material: PhysicsMaterialResource.generate(friction: 0.5, restitution: 0.0),
            mode: .kinematic // Kinematic objects are unaffected by forces but respond to gestures
        ))
    }
    
    @MainActor
    /// Set the speed of the automatic rotation
    /// - Parameter configuration: Configuration with rotation speed information.
    func updateRotation(configuration: GlobeConfiguration) {
        guard let modelEntity else { return }
        if var rotationComponent: RotationComponent = modelEntity.components[RotationComponent.self] {
            rotationComponent.speed = configuration.currentRotationSpeed
            rotationComponent.globeRadius = configuration.globe.radius
            modelEntity.components[RotationComponent.self] = rotationComponent
        } else {
            let rotationComponent = RotationComponent(
                speed: configuration.currentRotationSpeed,
                globeRadius: configuration.globe.radius
            )
            modelEntity.components.set(rotationComponent)
        }
    }
    
    /// Apply animated transformation. All values in global space. Stops any current animation and updates `self.animationPlaybackController`.
    /// - Parameters:
    ///   - scale: New scale. If nil, scale is not changed.
    ///   - orientation: New orientation. If nil, orientation is not changed.
    ///   - position: New position. If nil, position is not changed.
    ///   - duration: Duration of the animation.
    @discardableResult func animateTransform(
        scale: Float? = nil,
        orientation: simd_quatf? = nil,
        position: SIMD3<Float>? = nil,
        duration: Double = 2
    ) -> Transform {
        if let scale, abs(scale) < 0.000001 {
            Logger().warning("Animating the scale of an entity to 0 will cause a subsequent inverse of the entity's transform to return NaN values.")
        }
        let scale = scale == nil ? self.scale : [scale!, scale!, scale!]
        let orientation = orientation ?? self.orientation
        let position = position ?? self.position
        let transform = Transform(
            scale: scale,
            rotation: orientation,
            translation: position
        )
        animationPlaybackController?.stop()
        animationPlaybackController = move(to: transform, relativeTo: nil, duration: duration)
        if animationPlaybackController?.isPlaying == false {
            Logger().warning("move(to: relativeTo: duration:) animation not playing for '\(self.name)'.")
            self.transform = transform
        }
        return transform
    }
    
    /// Returns true if the globe axis is vertically oriented.
    var isNorthOriented: Bool {
        let eps: Float = 0.000001
        let axis = orientation.axis
        if !axis.x.isFinite || !axis.y.isFinite || !axis.z.isFinite {
            return true
        }
        return abs(axis.x) < eps && abs(abs(axis.y) - 1) < eps && abs(axis.z) < eps
    }
    
    /// North-orient the globe.
    /// - Parameter radius: The unscaled radius of the globe, needed for computing the duration of the animation. If nil a default duration is used for the animation..
    func orientToNorth(radius: Float? = nil) {
        let orientation = Self.orientToNorth(orientation: self.orientation)
        let duration = animationDuration(for: orientation, radius: radius)
        animateTransform(orientation: orientation, duration: duration)
    }
    
    /// Rotate an orientation quaternion, such that it is north-oriented.
    /// - Parameter orientation: The quaternion to orient.
    /// - Returns: A new quaternion.
    static func orientToNorth(orientation: simd_quatf) -> simd_quatf {
        // The up vector in the world space (y-axis)
        let worldUp = simd_float3(0, 1, 0)
        
        // Rotate the world up vector by the quaternion
        let localUp = orientation.act(worldUp)
        
        // Compute the axis to rotate around to align localUp with the world up vector
        let rotationAxis = normalize(simd_cross(localUp, worldUp))

        // The up vector and the rotated up vector are identical: return the passed orientation
        if !rotationAxis.x.isFinite || !rotationAxis.y.isFinite || !rotationAxis.z.isFinite {
            return orientation
        }
        
        // Compute the angle between localUp and the world up vector
        let dotProduct = simd_dot(localUp, worldUp)
        let angle = acos(dotProduct)

        // Create the quaternion that represents the rotation needed to align localUp with the world up vector
        let alignmentQuat = simd_quatf(angle: angle, axis: rotationAxis)
        
        // Apply the alignment quaternion to the original quaternion to remove the roll component
        return alignmentQuat * orientation
    }
    
    /// Rotates the globe such that a given point on the globe faces the camera.
    /// - Parameters:
    ///   - location: The point on the globe that is to face the camera relative to the center of the globe.
    ///   - radius: The unscaled radius of the globe, needed for computing the duration of the animation. If nil a default duration is used for the animation.
    func rotate(to location: SIMD3<Float>, radius: Float? = nil) {
        if let cameraPosition = CameraTracker.shared.position {
            // Unary vector in global space from the globe center to the camera.
            // This vector is pointing from the globe center toward the target position on the globe.
            let v = normalize(cameraPosition - position(relativeTo: nil))

            // rotate the point to the target position
            let orientation = simd_quatf(from: normalize(location), to: v)
//            orientation = Self.orientToNorth(orientation: orientation)
            
            let duration = animationDuration(for: orientation, radius: radius)
            animateTransform(orientation: orientation, duration: duration)
        }
    }
    
    /// Returns a duration in seconds for animating a transformation. Takes into account the size of the globe and the angular distance of the transformation.
    /// - Parameters:
    ///   - transformation: The transformation.
    ///   - radius: The unscaled radius of the globe. If nil, a default duration is returned.
    /// - Returns: Duration in seconds.
    func animationDuration(for transformation: simd_quatf, radius: Float?) -> Double {
        var duration = Self.transformAnimationDuration
        guard let radius else { return duration }
        // scale duration with current size of the globe if the scaled radius is greater than 1 meter
        // radius of 1 m -> 1, max radius -> max radius
        let scaledRadius = radius * meanScale
        let sizeScale = max(1, scaledRadius)
        duration *= Double(sizeScale)
        
        // Scale duration with the angle between the two quaternions: 0° -> 0, 180° -> 2
        // The angle is computed with https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation#Recovering_the_axis-angle_representation
        // let qd = (transformation.conjugate * orientation)
        // let angle = 2 * atan2(length(qd.imag), qd.real)
        var angle = (transformation.conjugate * orientation).angle
        
        // Normalize the angle if greater than 180 degrees.
        if angle > .pi {
            angle = abs(angle - 2 * .pi)
        }
        
        duration *= Double(angle / .pi * 2)
        
        return max(0.2, duration)
    }
    
    /// Returns true if the scaled size of the globe is close to the original size.
    /// - Parameters:
    ///   - radius: Radius of the globe in meter.
    ///   - tolerance: Tolerance in meter, default is 3 mm.
    /// - Returns: True if the size is close to the original.
    func isAtOriginalSize(radius: Float, tolerance: Float = 0.003) -> Bool {
        let eps = tolerance / radius
        return abs(scale.x - 1) < eps && abs(scale.y - 1) < eps && abs(scale.z - 1) < eps
    }
    
    /// Changes the scale of the globe and moves the globe along a line connecting the camera and the center of the globe,
    /// such that the globe section facing the camera remains at a constant distance.
    /// - Parameters:
    ///   - newScale: The new scale of the globe.
    ///   - oldScale: The current scale of the globe.
    ///   - oldPosition: The current position of the globe.
    ///   - cameraPosition: The camera position. If nil, the current camera position is retrieved.
    ///   - radius: Radius of the unscaled globe.
    ///   - duration: Animation duration in seconds.
    func scaleAndAdjustDistanceToCamera(
        newScale: Float,
        oldScale: Float,
        oldPosition: SIMD3<Float>,
        cameraPosition: SIMD3<Float>? = nil,
        radius: Float,
        duration: Double = 0
    ) {
        let cameraPosition = cameraPosition ?? (CameraTracker.shared.position ?? SIMD3(0, 1, 0))
        
        // Compute by how much the globe radius changes.
        let deltaRadius = (newScale - oldScale) * radius
        
        // The unary direction vector from the globe to the camera.
        let globeCameraDirection = normalize(cameraPosition - oldPosition)
        
        // Move the globe center along that direction.
        let position = oldPosition - globeCameraDirection * deltaRadius
        if duration > 0 {
            animateTransform(scale: newScale, position: position, duration: duration)
        } else {
            self.scale = [newScale, newScale, newScale]
            self.position = position
        }
    }
    
    /// Changes the scale of the globe and moves the globe along a line connecting the camera and the center of the globe,
    /// such that the globe section facing the camera remains at a constant distance.
    /// - Parameters:
    ///   - newScale: The new scale of the globe.
    ///   - radius: Radius of the unscaled globe.
    ///   - duration: Animation duration in seconds.
    func scaleAndAdjustDistanceToCamera(
        newScale: Float,
        radius: Float,
        duration: Double = 0
    ) {
        self.scaleAndAdjustDistanceToCamera(
            newScale: newScale,
            oldScale: meanScale,
            oldPosition: position,
            radius: radius,
            duration: duration
        )
    }
    
    /// Returns the distance between the closest point of globe surface to the camera and the camera position.
    /// - Parameter radius: Radius of the globe in meter.
    /// - Returns: Distance in meter.
    func distanceToCamera(radius: Float) throws -> Float  {
        guard let cameraPosition = CameraTracker.shared.position else {
            throw error("The camera position is unknown.")
        }
        let globeCenter = position(relativeTo: nil)
        return distance(cameraPosition, globeCenter) - radius
    }
    
    /// Move a globe toward the camera along a straight line.
    /// - Parameters:
    ///   - distance: The target distance between the camera and the closest point on the globe.
    ///   - radius: The radius of the globe.
    ///   - duration: Duration of the animation.
    func moveTowardCamera(distance: Float, radius: Float, duration: Double = 0) {
        guard let cameraPosition = CameraTracker.shared.position else { return }
        let globeCenter = position(relativeTo: nil)
        let v = normalize(globeCenter - cameraPosition)
        let newGlobeCenter = cameraPosition + v * (distance + radius)
        animateTransform(position: newGlobeCenter, duration: duration)
    }
    
    
    func respawnGlobe(_ newPlace: GlobePosition) {

        isInMovement = true
        
        let newPosition = newPlace.position
        
//        let randomRotationY = Float.random(in: -Float.pi...Float.pi)
        let fixedRotationY = Float.pi
        let newOrientation = simd_quatf(angle: fixedRotationY, axis: SIMD3<Float>(0, 1, 0))
        
        animateTransform(
            orientation: newOrientation,
            position: newPosition,
            duration: 0.2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isInMovement = false
        }
    }
    
    func refineGlobePosition(_ newCoordinate: SIMD3<Float>) {
        
        isInMovement = true
//        let randomRotationY = Float.random(in: -Float.pi...Float.pi)
        let fixedRotationY = Float.pi
        let newOrientation = simd_quatf(angle: fixedRotationY, axis: SIMD3<Float>(0, 1, 0))
        
        animateTransform(
            orientation: newOrientation,
            position: newCoordinate,
            duration: 0.2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isInMovement = false
        }
    }
    
    func xyCounterPosition(of position: SIMD3<Float>) -> SIMD3<Float> {
        return SIMD3(-position.x, -position.y, position.z)
    }
    
    
    func repositionGlobe() -> SIMD3<Float>? {
        
        isInMovement = true
        
        guard let cameraPosition = CameraTracker.shared.position else {
            print("Camera position is unknown.")
            return SIMD3<Float>(0.0, 0.8, -1.5)
        }
        
        var counterPosition: SIMD3<Float> = SIMD3<Float>(0.0, 0.8, -1.5)
        
//        PositionCondition.positionConditionsSetter(for: positionConditions,
//                                                       lastUsedIndex: &PositionCondition.lastUsedPositionConditionIndex)
        
        let (globeRotates, distance, direction) = PositionCondition.positionConditionsGetter(for: positionConditions,
                                                                             lastUsedIndex: PositionCondition.lastUsedPositionConditionIndex)
        

        let _: Bool = (globeRotates[0] == .rotating) ? true : false
        
        let distanceMultiplier: Float = (distance == .near) ? 1 : 1.5
        
        let offset: SIMD3<Float>
        
        
//        let randomiseHorizontal = Float.random(in: -0.5...0.5)
//        let randomiseVertical = Float.random(in: 0...1.8)
        
        switch direction {
        case .vertical:
            offset = SIMD3<Float>(0, 0.9, -1.5) * distanceMultiplier
            counterPosition = SIMD3<Float>(0, 0.9, -1.5) * distanceMultiplier
        case .horizontal:
            offset = SIMD3<Float>(-0.8, 0, -1.5) * distanceMultiplier
            counterPosition = SIMD3<Float>(0.8, 0, -1.5) * distanceMultiplier
        case .diagonal:
            offset = SIMD3<Float>(-0.5, 0.4, -1.5) * distanceMultiplier
            counterPosition = SIMD3<Float>(0.5, 1.5, -1.5) * distanceMultiplier
//        case .diagonalUp:
//            offset = SIMD3<Float>(randomiseHorizontalLeft, randomiseVerticalUp, -0.5) * distanceMultiplier
//            counterPosition = ["Center", "CenterUp", "RightUp", "Right"].randomElement()!
//        case .diagonalDown:
//            offset = SIMD3<Float>(randomiseHorizontalLeft, randomiseVerticalDown, -0.5) * distanceMultiplier
//            counterPosition = ["Center", "CenterDown", "RightDown", "Right"].randomElement()!
        case .none:
            offset = SIMD3<Float>(-0.8, 0.9, -1.5) * distanceMultiplier
            counterPosition = SIMD3<Float>(0.8, 0.9, -1.5) * distanceMultiplier
        }
        
        let newPosition = cameraPosition + offset
        animateTransform(position: newPosition, duration: 0.2)
                
        lastGlobeReposition = newPosition
        
        lastGlobeCounterReposition = counterPosition
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isInMovement = false
        }
        
        return counterPosition
    }
    
    func rerotateGlobe() -> simd_quatf {
        
        isInMovement = true
//        if useFirstRotationIndex {
//            RotationCondition.rotationConditionsSetter(for: rotationConditions,
//                                                       lastUsedIndex: &RotationCondition.lastUsedRotationConditionIndex)
//        }
                
        let (_, complexity) = RotationCondition.rotationConditionsGetter(for: rotationConditions, lastUsedIndex: RotationCondition.lastUsedRotationConditionIndex)
        
        //First globe rotation
        let firstRotationIntensity: Float = (complexity == .simple) ? 0.25 : 0.5
        let secondRotationIntensity: Float = (complexity == .simple) ? 0.125 : 0.375
        
        
        let rotationIntensity = useFirstRotationIndex ? firstRotationIntensity : secondRotationIntensity
                
        let yRotation = Float.pi * rotationIntensity
        
        var rotationQuaternion = simd_quatf(angle: yRotation, axis: SIMD3<Float>(0, 1, 0))
        
        if complexity == .complex {
            // Add rotations on X and Z axes
            let xRotation = Float.pi * (useFirstRotationIndex ? 0.25 : 0.125)
            let zRotation = Float.pi * (useFirstRotationIndex ? 0.125 : 0.25)
            
            let xRotationQuaternion = simd_quatf(angle: xRotation, axis: SIMD3<Float>(1, 0, 0))
            let zRotationQuaternion = simd_quatf(angle: zRotation, axis: SIMD3<Float>(0, 0, 1))
            
            // Combine rotations
            rotationQuaternion = simd_mul(simd_mul(xRotationQuaternion, zRotationQuaternion), rotationQuaternion)
        }
        
        // Second globe rotation
        let counterFirstRotationIntensity: Float = (complexity == .simple) ? -0.25 : -0.5
        let counterSecondRotationIntensity: Float = (complexity == .simple) ? -0.125 : -0.375
        
        
        let counterRotationIntensity = useFirstRotationIndex ? counterFirstRotationIntensity : counterSecondRotationIntensity
                
        let counterYRotation = Float.pi * counterRotationIntensity
        
        var counterRotationQuaternion = simd_quatf(angle: counterYRotation, axis: SIMD3<Float>(0, 1, 0))
        
        if complexity == .complex {
            // Add counter-rotations on X and Z axes
            let counterXRotation = Float.pi * (useFirstRotationIndex ? -0.25 : -0.125)
            let counterZRotation = Float.pi * (useFirstRotationIndex ? -0.125 : -0.25)

            let counterXRotationQuaternion = simd_quatf(angle: counterXRotation, axis: SIMD3<Float>(1, 0, 0))
            let counterZRotationQuaternion = simd_quatf(angle: counterZRotation, axis: SIMD3<Float>(0, 0, 1))

            // Combine counter-rotations
            counterRotationQuaternion = simd_mul(simd_mul(counterXRotationQuaternion, counterZRotationQuaternion), counterRotationQuaternion)
        }
        
        useFirstRotationIndex.toggle()

        animateTransform(orientation: rotationQuaternion, duration: 0.2)
        
//    Randomiser:
//        guard let cameraPosition = CameraTracker.shared.position else {
//            print("Camera position is unknown.")
//            return
//        }
//        let randomRotationY = Float.random(in: -Float.pi...Float.pi)
//        
//        let rotationQuaternion = simd_quatf(angle: randomRotationY, axis: SIMD3<Float>(0, 1, 0))
//        
//        animateTransform(orientation: rotationQuaternion, duration: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isInMovement = false
        }
        
        return counterRotationQuaternion
    }
    
    func rescaleGlobe() -> Float {
          
        isInMovement = true
        
//        if useFirstScaleIndex {
//            ScaleCondition.scaleConditionsSetter(for: scaleConditions,
//                                                 lastUsedIndex: &ScaleCondition.lastUsedScaleConditionIndex)
//        }
        
        let (_, zoomDirection) = ScaleCondition.scaleConditionsGetter(for: scaleConditions, lastUsedIndex: ScaleCondition.lastUsedScaleConditionIndex)
        
//        print("Current Condition: \(zoomDirection), useFirstScaleIndex: \(useFirstScaleIndex), is moving: \(movingGlobe)")
        
        let firstZoomScale: Float = (zoomDirection == .smallToLarge) ? 0.33 : 1.5
        let secondZoomScale: Float = (zoomDirection == .smallToLarge) ? 0.17 : 2.0
        
        let zoomDirectionScale = useFirstScaleIndex ? firstZoomScale : secondZoomScale
        
        let firstCounterScale: Float = (zoomDirection == .smallToLarge) ? 1.5 : 0.33
        let secondCounterScale: Float = (zoomDirection == .smallToLarge) ? 2.0 : 0.17
        
        let counterScale = useFirstScaleIndex ? firstCounterScale: secondCounterScale
        
//        print("Applying Scale: \(zoomDirectionScale), Counter Scale: \(counterScale)")

        
        useFirstScaleIndex.toggle()
        
        animateTransform(scale: zoomDirectionScale, duration: 0.2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isInMovement = false
        }
        
        return counterScale
    }
    
    /// The  mean scale factor of this entity relative to the world space.
    @MainActor
    var meanScale: Float { scale(relativeTo: nil).sum() / 3 }
}
