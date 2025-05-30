import ARKit
import RealityKit
import SwiftUI
import simd

extension View {
    /// Adds gestures for moving, scaling and rotating a globe.
    @MainActor
    func globeGestures(model: ViewModel, studyModel: StudyModel) -> some View {
        self.modifier(
            GlobeGesturesModifier(model: model, studyModel: studyModel)
        )
    }
}

/// A modifier that adds gestures for moving, scaling and rotating a globe.
@MainActor
private struct GlobeGesturesModifier: ViewModifier {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpaceAction
    
    /// State variables for drag, magnify, scale and 3D rotation gestures. State variables for the y-rotation gesture is separate.
    struct GlobeGestureState {
        var isDragging = false
        var isScaling: Bool { scaleAtGestureStart != nil }
        var isRotating: Bool { orientationAtGestureStart != nil }
        
        /// The position of the globe at the start of a drag or magnify gesture in world coordinates
        var positionAtGestureStart: SIMD3<Float>? = nil
        
        /// The scale of the globe at the start of a magnify gesture
        var scaleAtGestureStart: Float? = nil
        
        /// The orientation of the globe at the start of a 3D rotation gesture.
        var orientationAtGestureStart: Rotation3D? = nil
        
        /// The orientation of the globe at the start of a drag gesture in the local coordinate system of the entity;
        /// used to orient the globe such that the same location is facing the camera while the globe is moved.
        var localRotationAtGestureStart: simd_quatf? = nil
        
        /// The position of the camera at the start of a magnify gesture
        var cameraPositionAtGestureStart: SIMD3<Float>? = nil
        
        /// Automatic rotation is paused during a gesture. `isRotationPausedAtStartOfGesture` remembers whether the rotation was paused before the gesture started.
        var isRotationPausedAtGestureStart: Bool? = nil
        
        /// Location of drag gesture for rotating the globe around its rotation axis
        var previousLocation3D: Point3D? = nil
        
        /// This var marks the proximity distance of globes
        let inProximityRange: Float = 0.75
        
        /// Direction in which second globe is responding during first globe scaling
        var directionVector: SIMD3<Float>? = .zero
        
        /// Temporary entity for reference during gestures (frame of reference for x-y axes)
        var rotatedEntity: Entity? = nil
        
        /// Variable that contains last state of orientation
        var resetRotation: simd_quatf? = nil
        
        /// Variable that contains last reference of axes
        var referenceRotation: simd_quatf? = nil
        
        var initialLocalX: SIMD3<Float>?
        
        var initialLocalY: SIMD3<Float>?
        
        
        /// Reset all temporary properties.
        mutating func endGesture() {
            isDragging = false
            positionAtGestureStart = nil
            scaleAtGestureStart = nil
            orientationAtGestureStart = nil
            localRotationAtGestureStart = nil
            cameraPositionAtGestureStart = nil
            isRotationPausedAtGestureStart = nil
            previousLocation3D = nil
        }
    }
    
    let model: ViewModel
    let studyModel: StudyModel
    
    @State private var state = GlobeGestureState()
    
    enum RotationState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
    }
    
    @GestureState private var rotationState = RotationState.inactive
    
    @State private var isInRotatingState: Bool = false
    
    private var minimumLongPressDuration: Double {
        if studyModel.currentPage == .outroForm {
            return 0.3
        } else {
            return 0.0
        }
    }
    
    /// Amount of angular rotation per translation delta for single-handed rotation around the y-axis. This value is reduced for enlarged globes.
    private let rotationSpeed: Float = 0.0015
    
    // duration of an animate run each time the transformation changes, as in the Apple EntityGestures sample project
    private let animationDuration = 0.2
    
    /// If the globes is farther away than this distance and it is tapped to show an attachment view.
    private let maxDistanceToCameraWhenTapped: Float = 1.5
    
    let soundManager = SoundManager.shared
    
    private func showNextPageOnWindow() {
        openWindow(id: ViewModel.windowID)
        studyModel.currentPage = studyModel.currentPage.next()
    }
    
    @ViewBuilder
    func body(content: Content) -> some View {
        switch studyModel.currentPage {
            
        case .positionTraining:
            content
                .simultaneousGesture(dragTrainingGesture)
            
        case    .positionExperiment1,
                .positionExperiment2:
            content
                .simultaneousGesture(dragGesture)
        case    .positionExperimentForm1,
                .positionExperimentForm2, .positionComparison:
            content
                .simultaneousGesture(dragTrainingGesture)
        case .rotationTraining1, .rotationExperimentForm1, .rotationTraining2, .rotationExperimentForm2:
            if model.oneHandedRotationGesture {
                content
                    .simultaneousGesture(rotateGlobeAxisTrainingGesture)
            } else {
                content
                    .simultaneousGesture(rotateTrainingGesture)
            }
            
        case    .rotationExperiment1,
                .rotationExperiment2:
            if model.oneHandedRotationGesture {
                content
                    .simultaneousGesture(rotateGlobeAxisGesture)
            } else {
                content
                    .simultaneousGesture(rotateGesture)
            }
            
        case .rotationComparison:
            if model.oneHandedRotationGesture {
                content
                    .simultaneousGesture(rotateGlobeAxisTrainingGesture)
            } else {
                content
                    .simultaneousGesture(rotateTrainingGesture)
            }
            
        case .scaleTraining:
            content
                .simultaneousGesture(magnifyTrainingGesture)
        case    .scaleExperiment1,
                .scaleExperiment2:
            content
                .simultaneousGesture(magnifyGesture)
        case    .scaleExperimentForm1,
                .scaleExperimentForm2, .scaleComparison:
            content
                .simultaneousGesture(magnifyTrainingGesture)
        case .outroForm:
            if model.oneHandedRotationGesture {
                content
                    .simultaneousGesture(dragTrainingGesture)
                    .simultaneousGesture(magnifyTrainingGesture)
                    .simultaneousGesture(rotateGlobeAxisTrainingGesture)
            } else {
                content
                    .simultaneousGesture(dragTrainingGesture)
                    .simultaneousGesture(magnifyTrainingGesture)
                    .simultaneousGesture(rotateTrainingGesture)
            }
            
        default :
            content
                .simultaneousGesture(dragTrainingGesture)
                .simultaneousGesture(magnifyTrainingGesture)
                .simultaneousGesture(rotateTrainingGesture)
                .simultaneousGesture(rotateGlobeAxisTrainingGesture)
        }

    }
    
    /// Convert a position on the globe in Cartesian coordinates to spherical coordinates.
    /// - Parameter xyz: Position in Cartesian coordinates on the globe.
    /// - Returns: Latitude and longitude on the globe.
    private static func xyzToLatLon(xyz: SIMD3<Float>) -> (latitude: Angle, longitude: Angle) {
        let x = Double(xyz.z)
        let y = Double(xyz.x)
        let z = Double(xyz.y)
        
        let r = sqrt(x * x + y * y + z * z)
        let lat = .pi / 2 - acos(z / r)
        let lon = atan2(y, x) + .pi / 2
        
        return (Angle(radians: lat), Angle(radians: lon))
    }
    
    /// Double pinch gesture for starting and stoping globe rotation.
    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .targetedToAnyEntity()
            .onEnded { value in
                model.configuration.isRotationPaused.toggle()
            }
        
        //        SpatialTapGesture()
        //            .targetedToAnyEntity()
        //            .onEnded { event in
        //                if let entity = model.globeEntity {
        //                    let location3D = event.convert(event.location3D, from: .local, to: entity)
        //                    entity.rotate(to: location3D, radius: model.globe.radius)
        //                }
        //            }
    }
    
    /// Drag gesture to reposition the globe.
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .targetedToAnyEntity()
            .onChanged { value in
                Task { @MainActor in
                    guard let globeEntity = value.entity as? GlobeEntity else { return }
                    
                    // Determine if it's the first or second globe
                    let isFirstGlobe = (globeEntity == model.firstGlobeEntity)
                    //                    let isSecondGlobe = (globeEntity == model.secondGlobeEntity)
                    guard isFirstGlobe else {
                        log("Ignoring drag gesture on secondGlobe")
                        return
                    }
                    guard globeEntity.isInMovement == false else {
                        log("Ignoring gesture due to its current movement")
                        return
                    }
                    guard !state.isScaling,
                          !state.isRotating,
                          !rotationState.isActive else {
                        log("exit drag")
                        return
                    }
                    if state.positionAtGestureStart == nil {
                        log("start drag")
                        state.isDragging = true
                        state.positionAtGestureStart = value.entity.position(relativeTo: nil)
                        state.localRotationAtGestureStart = (value.entity as? GlobeEntity)?.orientation
                        
                        let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                        let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                        studyModel.setupNextTask(gestureType: .position, targetTransform: targetTransform)
                        studyModel.currentTask?.start(type: .position,
                                                      originalTransform: originalTransform,
                                                      targetTransform: targetTransform)
                        
                    }
                    
                    if let positionAtGestureStart = state.positionAtGestureStart,
                       let localRotationAtGestureStart = state.localRotationAtGestureStart,
                       let globeEntity = value.entity as? GlobeEntity,
                       let cameraPosition = CameraTracker.shared.position {
                        log("update drag")
                        let location3D = value.convert(value.location3D, from: .local, to: .scene)
                        let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                        let delta = location3D - startLocation3D
                        let newPosition = positionAtGestureStart + SIMD3<Float>(delta)
                        
                        // rotate the globe around a vertical axis (which is different to the globe's axis if it is not north-oriented)
                        // such that the same location is facing the camera as the globe is dragged horizontally around the camera
                        let newRotation: simd_quatf?
                        if model.rotateGlobeWhileDragging {
                            var v1 = cameraPosition - positionAtGestureStart
                            var v2 = cameraPosition - newPosition
                            v1.y = 0
                            v2.y = 0
                            v1 = normalize(v1)
                            v2 = normalize(v2)
                            let rotationSinceStart = simd_quatf(from: v1, to: v2)
                            let localRotationSinceStart = simd_quatf(value.convert(rotation: rotationSinceStart, from: .scene, to: .local))
                            newRotation = simd_mul(localRotationSinceStart, localRotationAtGestureStart)
                        } else {
                            newRotation = nil
                        }
                        
                        // animate the transformation to reduce jitter, as in the Apple EntityGestures sample project
                        var originalTransform = globeEntity.transform
                        
                        originalTransform = globeEntity.animateTransform(orientation: newRotation,
                                                                         position: newPosition,
                                                                         duration: animationDuration)
                        
                        guard var currentTask = studyModel.currentTask else {
                            log("Error: currentTask is nil. Cannot add action")
                            return
                        }
                        let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                        
                        currentTask.addAction(StudyAction(
                            actionID: currentTask.actionID,
                            type: .position,
                            status: .drag,
                            originalTransform: originalTransform,
                            targetTransform: targetTransform))
                        
                        
                        // This function applies transparency to second globe if it is in proximity to the first globe
                        let globesDistance = simd_distance(originalTransform.translation,targetTransform.translation)
                        
                        if let secondGlobeEntity = model.secondGlobeEntity {
                            if globesDistance < state.inProximityRange {
                                model.globesInProximity = true
                                if secondGlobeEntity.components.has(OpacityComponent.self) {
                                    secondGlobeEntity.components[OpacityComponent.self] = OpacityComponent(opacity: 0.6)
                                } else {
                                    secondGlobeEntity.components.set(OpacityComponent(opacity: 1.0))
                                }
                            } else {
                                model.globesInProximity = false
                            }
                        }
                    }
                }
            }
            .onEnded { value in
                log("end drag")
                state.endGesture()
                let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                studyModel.currentTask?.end(type: .position,
                                            originalTransform: originalTransform,
                                            targetTransform: targetTransform)
                
                studyModel.currentTask?.updateAccuracyResult()
                if studyModel.currentPage.isStoringRecordNeeded {
                    studyModel.storeTask()
                }
                if studyModel.currentTask?.isMatching == true {
                    SoundManager.shared.playSound(named: "correct")
                    studyModel.currentTask = nil
                    if studyModel.taskCompleted(gestureType: .position) {
                        if studyModel.positionTaskRepetitionCount % 2 != 0 {
                            model.firstGlobeEntity?.refineGlobePosition(model.firstGlobeEntity?.lastGlobeCounterReposition ?? SIMD3<Float>(0,0.9,-0.5))
                            model.secondGlobeEntity?.refineGlobePosition(model.firstGlobeEntity?.lastGlobeReposition ?? SIMD3<Float>(0,0.9,-0.5))
                        } else {
                            model.firstGlobeEntity?.refineGlobePosition(model.firstGlobeEntity?.lastGlobeReposition ?? SIMD3<Float>(0,0.9,-0.5))
                            model.secondGlobeEntity?.refineGlobePosition(model.firstGlobeEntity?.lastGlobeCounterReposition ?? SIMD3<Float>(0,0.9,-0.5))
                        }
                    } else {
                        let counterPosition = model.firstGlobeEntity?.repositionGlobe()
                        PositionCondition.positionConditionsSetter(for: model.positionConditions,
                                                                   lastUsedIndex: &PositionCondition.lastUsedPositionConditionIndex)
                        model.secondGlobeEntity?.refineGlobePosition(counterPosition ?? SIMD3<Float>(0,0.9,-0.5))
                        if PositionCondition.positionConditionsCompleted == true {
                            showNextPageOnWindow()
                        }
                    }
                }
            }
    }
    
    private var magnifyGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .targetedToAnyEntity()
            .onChanged { value in
                Task { @MainActor in
                    guard let globeEntity = value.entity as? GlobeEntity
                    else { return }
                    
                    if let secondGlobeEntity = model.secondGlobeEntity {
                        
                        // Below is the setup in executing responsive secondGlobe movement to first globe scale
                        let from = globeEntity.position(relativeTo: nil)
                        let to = secondGlobeEntity.position(relativeTo: nil)
                        let rawDirection = to - from
                        let direction = length(rawDirection) == 0 ? [1, 0, 0] : normalize(rawDirection)
                        state.directionVector = direction
                    }
                    
                    guard !state.isRotating, !rotationState.isActive else {
                        log("exit magnify")
                        return
                    }
                    
                    let isFirstGlobe = (globeEntity == model.firstGlobeEntity)
                    guard isFirstGlobe else {
                        log("Ignoring magnify gesture on secondGlobe")
                        return
                    }
                    guard globeEntity.isInMovement == false else {
                        log("Ignoring gesture due to its current movement")
                        return
                    }
                    
                    if !state.isScaling {
                        log("start magnify")
                        state.scaleAtGestureStart = globeEntity.meanScale
                        state.positionAtGestureStart = value.entity.position
                        // The camera position at the start of the scaling gesture is used to move the globe.
                        // Querying the position on each update would result in an unstable globe position if the camera is moved.
                        state.cameraPositionAtGestureStart = CameraTracker.shared.position
                        
                        let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                        let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                        studyModel.setupNextTask(gestureType: .scale, targetTransform: targetTransform)
                        studyModel.currentTask?.start(type: .scale,
                                                      originalTransform: originalTransform,
                                                      targetTransform: targetTransform)
                        
                    }
                    

                    
                    if let globeScaleAtGestureStart = state.scaleAtGestureStart,
                       let globePositionAtGestureStart = state.positionAtGestureStart,
                       let cameraPositionAtGestureStart = state.cameraPositionAtGestureStart {
                        log("update magnify")
                        let scale = max(model.configuration.minScale, min(model.configuration.maxScale, Float(value.magnification) * globeScaleAtGestureStart))
                        
                        if model.moveGlobeWhileScaling {
                            globeEntity.scaleAndAdjustDistanceToCamera(
                                newScale: scale,
                                oldScale: globeScaleAtGestureStart,
                                oldPosition: globePositionAtGestureStart,
                                cameraPosition: cameraPositionAtGestureStart,
                                radius: model.globe.radius,
                                duration: animationDuration // animate the transformation to reduce jitter, as in the Apple EntityGestures sample project
                            )
                            
                        } else {
                            globeEntity.scale = [scale, scale, scale]
                        }
                        
                        
                       // This function below adjusts second globe's z-axis position according to the scale of the first globe.
                       // It only applies when the study's scaling condition is in "Adjust distance to the camera when scaling"
                        if let secondGlobeEntity = model.secondGlobeEntity {
                            if model.moveGlobeWhileScaling {

                                let globeOldScale = (globeEntity.scale.x + globeEntity.scale.y + globeEntity.scale.z) / 3
                                secondGlobeEntity.adjustDistanceToCamera(
                                    newScale: scale,
                                    oldScale: globeOldScale,
                                    oldPosition: secondGlobeEntity.position,
                                    cameraPosition: cameraPositionAtGestureStart,
                                    radius: model.globe.radius,
                                    duration: animationDuration // animate the transformation to reduce jitter, as in the Apple EntityGestures sample project
                                )
                            }
                        }
                        
                      //   This function below adjusts second globe's position according to the scale of the first globe
                        if let secondGlobeEntity = model.secondGlobeEntity,
                           let direction = state.directionVector {
                            
                            let defaultRadius = model.globe.radius
                            let secondGlobeScale = (secondGlobeEntity.scale.x + secondGlobeEntity.scale.y + secondGlobeEntity.scale.z) / 3.0
                            let secondRadius = secondGlobeScale * defaultRadius
                            let currentRadius = scale * defaultRadius
                            let middleOffset: Float = 0.35
                            let requiredDistance = currentRadius + secondRadius + middleOffset
                            
                            let basePosition = globeEntity.position(relativeTo: nil)
                            let newSecondGlobePosition = basePosition + (direction * requiredDistance) 
                            
                            let currentPosition = secondGlobeEntity.position(relativeTo: nil)
                            let distanceThreshold: Float = 0.001
                            
                            if distance(currentPosition, newSecondGlobePosition) > distanceThreshold {
                                secondGlobeEntity.animateTransform(
                                    orientation: secondGlobeEntity.orientation,
                                    position: newSecondGlobePosition,
                                    duration: animationDuration
                                )
                            }
                        }
                    }
                    
                    var originalTransform = globeEntity.transform
                    
                    originalTransform = globeEntity.animateTransform(orientation: globeEntity.orientation,
                                                                     position: globeEntity.position,
                                                                     duration: animationDuration)
                    
                    guard var currentTask = studyModel.currentTask else {
                        log("Error: currentTask is nil. Cannot add action")
                        return
                    }
                    let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                    currentTask.addAction(StudyAction(
                        actionID: currentTask.actionID,
                        type: .scale,
                        status: .magnify,
                        originalTransform: originalTransform,
                        targetTransform: targetTransform))
                    
                }
            }
            .onEnded { _ in
                state.endGesture()
                log("end magnify")
                let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                studyModel.currentTask?.end(type: .scale,
                                            originalTransform: originalTransform,
                                            targetTransform: targetTransform)
                
                studyModel.currentTask?.updateAccuracyResult()
                if studyModel.currentPage.isStoringRecordNeeded {
                    studyModel.storeTask()
                }
                if studyModel.currentTask?.isMatching == true {
                    //                    studyModel.currentTask?.updateAccuracyResult()
                    //                    studyModel.storeTask()
                    SoundManager.shared.playSound(named: "correct")
                    studyModel.currentTask = nil
                    if studyModel.taskCompleted(gestureType: .scale) {
                        if studyModel.scaleTaskRepetitionCount % 2 != 0 {
                            model.firstGlobeEntity?.respawnGlobe(.rightClose)
                            model.secondGlobeEntity?.respawnGlobe(.leftClose)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let counterScale = model.firstGlobeEntity?.rescaleGlobe()
                                model.secondGlobeEntity?.animateTransform(scale: counterScale, duration: 0.2)
                            }
                        } else {
                            model.firstGlobeEntity?.respawnGlobe(.leftClose)
                            model.secondGlobeEntity?.respawnGlobe(.rightClose)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let counterScale = model.firstGlobeEntity?.rescaleGlobe()
                                model.secondGlobeEntity?.animateTransform(scale: counterScale, duration: 0.2)
                            }
                        }
                    } else {
                        model.firstGlobeEntity?.respawnGlobe(.leftClose)
                        model.secondGlobeEntity?.respawnGlobe(.rightClose)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let counterScale = model.firstGlobeEntity?.rescaleGlobe()
                            model.secondGlobeEntity?.animateTransform(scale: counterScale, duration: 0.2)
                        }
                        ScaleCondition.scaleConditionsSetter(for: model.scaleConditions,
                                                             lastUsedIndex: &ScaleCondition.lastUsedScaleConditionIndex)
                        
                        if ScaleCondition.scaleConditionsCompleted == true {
                            showNextPageOnWindow()
                        }
                    }
                }
            }
    }
    
    /// Two-handed rotation gesture for 3D rotation.
    private var rotateGesture: some Gesture {
        RotateGesture3D()
            .targetedToAnyEntity()
            .onChanged { value in
                Task { @MainActor in
                    guard let globeEntity = value.entity as? GlobeEntity else { return }
                    
                    guard !state.isScaling, !rotationState.isActive else {
                        log ("exit rotate")
                        return
                    }
                    
                    let isFirstGlobe = (globeEntity == model.firstGlobeEntity)
                    guard isFirstGlobe else {
                        log("Ignoring rotate gesture on secondGlobe")
                        return
                    }
                    guard globeEntity.isInMovement == false else {
                        log("Ignoring gesture due to its current movement")
                        return
                    }
                    
                    if !state.isRotating {
                        log("start rotate")
                        state.orientationAtGestureStart = .init(value.entity.orientation(relativeTo: nil))
                        Task { @MainActor in
                            pauseRotationAndStoreRotationState()
                            let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                            let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                            studyModel.setupNextTask(gestureType: .rotation, targetTransform: targetTransform)
                            studyModel.currentTask?.start(type: .rotation,
                                                          originalTransform: originalTransform,
                                                          targetTransform: targetTransform)
                            
                        }
                    }
                    

                    
                    if let globeEntity = value.entity as? GlobeEntity,
                       let orientationAtGestureStart = state.orientationAtGestureStart {
                        log("update rotate")
                        
                        // reduce the rotation angle for enlarged globes to avoid excessively fast movements
                        let rotation = value.rotation
                        let scale = max(1, Double(globeEntity.meanScale))
                        let angle = Angle2D(radians: rotation.angle.radians / scale)
                        
                        // Flip orientation of rotation to match rotation direction of hands.
                        // Flipping code from "GestureComponent.swift" of Apple sample code project "Transforming RealityKit entities using gestures"
                        // https://developer.apple.com/documentation/realitykit/transforming-realitykit-entities-with-gestures?changes=_8
                        let flippedRotation = Rotation3D(angle: angle,
                                                         axis: RotationAxis3D(x: -rotation.axis.x,
                                                                              y: rotation.axis.y,
                                                                              z: -rotation.axis.z))
                        
                        let newOrientation = orientationAtGestureStart.rotated(by: flippedRotation)
                        globeEntity.animationPlaybackController?.stop()
                        globeEntity.orientation = simd_quatf(newOrientation)
                    }
                    let currentScale = globeEntity.scale
                    let averageScale = (currentScale.x + currentScale.y + currentScale.z) / 3
                    
                    //                    var originalTransform = globeEntity.transform
                    
                    let originalTransform = globeEntity.animateTransform(orientation: globeEntity.orientation,
                                                                         position: globeEntity.position,
                                                                         duration: animationDuration)
                    globeEntity.scale = SIMD3<Float>(repeating: averageScale)
                    
                    guard var currentTask = studyModel.currentTask else {
                        log("Error: currentTask is nil. Cannot add action")
                        return
                    }
                    let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                    currentTask.addAction(StudyAction(
                        actionID: currentTask.actionID,
                        type: .rotation,
                        status: .rotate,
                        originalTransform: originalTransform,
                        targetTransform: targetTransform))
                    
                }
            }
            .onEnded { value in
                log("end rotate")
                
                // Reset the previous rotation state
                if let paused = state.isRotationPausedAtGestureStart {
                    model.configuration.isRotationPaused = paused
                }
                
                state.endGesture()
                let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                studyModel.currentTask?.end(type: .rotation,
                                            originalTransform: originalTransform,
                                            targetTransform: targetTransform)
                
                studyModel.currentTask?.updateAccuracyResult()
                if studyModel.currentPage.isStoringRecordNeeded {
                    studyModel.storeTask()
                }
                if studyModel.currentTask?.isMatching == true {
                    SoundManager.shared.playSound(named: "correct")
                    studyModel.currentTask = nil
                    if studyModel.taskCompleted(gestureType: .rotation) {
                        if studyModel.rotationTaskRepetitionCount % 2 != 0 {
                            model.firstGlobeEntity?.respawnGlobe(.rightClose)
                            model.secondGlobeEntity?.respawnGlobe(.leftClose)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let counterRotation = model.firstGlobeEntity?.rerotateGlobe()
                                model.secondGlobeEntity?.animateTransform(orientation: counterRotation, duration: 0.2)
                            }
                        } else {
                            model.firstGlobeEntity?.respawnGlobe(.leftClose)
                            model.secondGlobeEntity?.respawnGlobe(.rightClose)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let counterRotation = model.firstGlobeEntity?.rerotateGlobe()
                                model.secondGlobeEntity?.animateTransform(orientation: counterRotation, duration: 0.2)
                            }
                        }
                    } else {
                        model.firstGlobeEntity?.respawnGlobe(.leftClose)
                        model.secondGlobeEntity?.respawnGlobe(.rightClose)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let counterRotation = model.firstGlobeEntity?.rerotateGlobe()
                            model.secondGlobeEntity?.animateTransform(orientation: counterRotation, duration: 0.2)
                        }
                        RotationCondition.rotationConditionsSetter(for: model.rotationConditions,
                                                                   lastUsedIndex: &RotationCondition.lastUsedRotationConditionIndex)
                        if RotationCondition.rotationConditionsCompleted == true {
                            showNextPageOnWindow()
                        }
                    }
                }
            }
    }
    
    /// One-handed gesture to rotate globe around the x and  y axes.
    private var rotateGlobeAxisGesture: some Gesture {
        LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture(minimumDistance: 0.0))
            .targetedToAnyEntity()
            .updating($rotationState) { value, rotationState, _ in
                guard let entity = value.entity as? GlobeEntity else { return }
                switch value.gestureValue {
                    // Long press begins.
                case .first(true):
                    rotationState = .pressing
                    
                    // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    
                    let isFirstGlobe = (entity == model.firstGlobeEntity)
                    
                    guard isFirstGlobe else {
                        log("Ignoring magnify gesture on secondGlobe")
                        return
                    }
                    guard entity.isInMovement == false else {
                        log("Ignoring gesture due to its current movement")
                        return
                    }
                    Task{
                        if isInRotatingState == false {
                            let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                            let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                            studyModel.setupNextTask(gestureType: .rotation, targetTransform: targetTransform)
                            studyModel.currentTask?.start(type: .rotation,
                                                          originalTransform: originalTransform,
                                                          targetTransform: targetTransform)
                            isInRotatingState = true
                        }
                    }
                    Task { @MainActor in
                        pauseRotationAndStoreRotationState()
                    }
                    
                    guard let drag = drag else { return }
                    
                    Task { @MainActor in
                        
                        if state.orientationAtGestureStart == nil {
                            state.orientationAtGestureStart = Rotation3D(entity.orientation)
                        }
                        
                        if let globeEntity = value.entity as? GlobeEntity,
                           let orientationAtGestureStart = state.orientationAtGestureStart {
                            log("update rotate")
                            
                            let dragTranslation = drag.translation
                            
                            // reduce the rotation angle for enlarged globes to avoid excessively fast movements
                            //                            let rotation = value.rotation
                            let scale = max(1, Float(globeEntity.meanScale) * model.globe.radius)
                            let angleX = Angle2D(radians: Double(Float(dragTranslation.height) * rotationSpeed / scale))
                            let angleY = Angle2D(radians: Double(Float(dragTranslation.width) * rotationSpeed / scale))
                            
                            // Originally it flips orientation of rotation to match rotation direction of hands, for two-handed.
                            // Flipping code from "GestureComponent.swift" of Apple sample code project "Transforming RealityKit entities using gestures"
                            // https://developer.apple.com/documentation/realitykit/transforming-realitykit-entities-with-gestures?changes=_8
                            let rotationX = Rotation3D(angle: angleY, axis: RotationAxis3D(x: 0, y: 1, z: 0))
                            let rotationY = Rotation3D(angle: angleX, axis: RotationAxis3D(x: 1, y: 0, z: 0))
                            
                            let newOrientation = orientationAtGestureStart
                                .rotated(by: rotationX)
                                .rotated(by: rotationY)
                            
                            // Apply the rotation to the globe
                            globeEntity.animationPlaybackController?.stop()
                            globeEntity.orientation = simd_quatf(newOrientation)
                            
                            let currentScale = globeEntity.scale
                            let averageScale = (currentScale.x + currentScale.y + currentScale.z) / 3
                            
                            //                            var originalTransform = globeEntity.transform
                            
                            let originalTransform = globeEntity.animateTransform(scale: averageScale, orientation: globeEntity.orientation,
                                                                                 position: globeEntity.position,
                                                                                 duration: animationDuration)
                            
                            globeEntity.scale = SIMD3<Float>(repeating: averageScale)
                            
                            
                            guard var currentTask = studyModel.currentTask else {
                                log("Error: currentTask is nil. Cannot add action")
                                return
                            }
                            let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                            currentTask.addAction(StudyAction(
                                actionID: currentTask.actionID,
                                type: .rotation,
                                status: .rotate,
                                originalTransform: originalTransform,
                                targetTransform: targetTransform))
                            
                        }
                    }
                    
                default:
                    rotationState = .inactive
                }
            }
            .onEnded { value in
                isInRotatingState = false
                switch value.gestureValue {
                case .second(true, _):
                    // Reset the previous rotation state
                    if let paused = state.isRotationPausedAtGestureStart {
                        model.configuration.isRotationPaused = paused
                    }
                    
                    state.endGesture()
                    let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                    let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                    studyModel.currentTask?.end(type: .rotation,
                                                originalTransform: originalTransform,
                                                targetTransform: targetTransform)
                    
                    studyModel.currentTask?.updateAccuracyResult()
                    if studyModel.currentPage.isStoringRecordNeeded {
                        studyModel.storeTask()
                    }
                    if studyModel.currentTask?.isMatching == true {

                        SoundManager.shared.playSound(named: "correct")
                        studyModel.currentTask = nil
                        if studyModel.taskCompleted(gestureType: .rotation) {
                            if studyModel.rotationTaskRepetitionCount % 2 != 0 {
                                model.firstGlobeEntity?.respawnGlobe(.rightClose)
                                model.secondGlobeEntity?.respawnGlobe(.leftClose)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    let counterRotation = model.firstGlobeEntity?.rerotateGlobe()
                                    model.secondGlobeEntity?.animateTransform(orientation: counterRotation, duration: 0.2)
                                }
                            } else {
                                model.firstGlobeEntity?.respawnGlobe(.leftClose)
                                model.secondGlobeEntity?.respawnGlobe(.rightClose)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    let counterRotation = model.firstGlobeEntity?.rerotateGlobe()
                                    model.secondGlobeEntity?.animateTransform(orientation: counterRotation, duration: 0.2)
                                }
                            }
                        } else {
                            model.firstGlobeEntity?.respawnGlobe(.leftClose)
                            model.secondGlobeEntity?.respawnGlobe(.rightClose)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let counterRotation = model.firstGlobeEntity?.rerotateGlobe()
                                model.secondGlobeEntity?.animateTransform(orientation: counterRotation, duration: 0.2)
                            }
                            RotationCondition.rotationConditionsSetter(for: model.rotationConditions,
                                                                       lastUsedIndex: &RotationCondition.lastUsedRotationConditionIndex)
                            if RotationCondition.rotationConditionsCompleted == true {
                                showNextPageOnWindow()
                            }
                        }
                    }
                default:
                    break
                }
            }
    }
    
    /// Helper gesture to reposition the globe in scaling
    private var dragHelperGesture: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .targetedToAnyEntity()
            .onChanged { value in
                Task { @MainActor in
                    guard !state.isScaling,
                          !state.isRotating,
                          !rotationState.isActive else {
                        log("exit drag")
                        return
                    }
                    if state.positionAtGestureStart == nil {
                        log("start drag")
                        state.isDragging = true
                        state.positionAtGestureStart = value.entity.position(relativeTo: nil)
                        state.localRotationAtGestureStart = (value.entity as? GlobeEntity)?.orientation
                    }
                    
                    if let positionAtGestureStart = state.positionAtGestureStart,
                       let localRotationAtGestureStart = state.localRotationAtGestureStart,
                       let globeEntity = value.entity as? GlobeEntity,
                       let cameraPosition = CameraTracker.shared.position {
                        log("update drag")
                        let location3D = value.convert(value.location3D, from: .local, to: .scene)
                        let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                        let delta = location3D - startLocation3D
                        let newPosition = positionAtGestureStart + SIMD3<Float>(delta)
                        let newRotation: simd_quatf?
                        
                        
                        if model.rotateGlobeWhileDragging {
                            var v1 = cameraPosition - positionAtGestureStart
                            var v2 = cameraPosition - newPosition
                            v1.y = 0
                            v2.y = 0
                            v1 = normalize(v1)
                            v2 = normalize(v2)
                            let rotationSinceStart = simd_quatf(from: v1, to: v2)
                            let localRotationSinceStart = simd_quatf(value.convert(rotation: rotationSinceStart, from: .scene, to: .local))
                            newRotation = simd_mul(localRotationSinceStart, localRotationAtGestureStart)
                            
                        } else {
                            newRotation = nil
                        }
                        // animate the transformation to reduce jitter, as in the Apple EntityGestures sample project
                        // below is the function to make the second globe moves along with first globe
                        if let firstGlobeEntity = model.firstGlobeEntity {
                            if let secondGlobeEntity = model.secondGlobeEntity {
                                
                                if globeEntity == model.firstGlobeEntity{
                                    globeEntity.animateTransform(orientation: newRotation, position: newPosition, duration: animationDuration)
                                    let secondGlobeNewPosition = secondGlobeEntity.position(relativeTo: nil) + (newPosition - firstGlobeEntity.position(relativeTo: nil))
                                    secondGlobeEntity.animateTransform(orientation: newRotation, position: secondGlobeNewPosition, duration: animationDuration)
                                }
                                else {
                                    globeEntity.animateTransform(orientation: newRotation, position: newPosition, duration: animationDuration)
                                    let firstGlobeNewPosition = firstGlobeEntity.position(relativeTo: nil) + (newPosition - secondGlobeEntity.position(relativeTo: nil))
                                    firstGlobeEntity.animateTransform(orientation: newRotation, position: firstGlobeNewPosition, duration: animationDuration)
                                }
                            }
                            else {
                                globeEntity.animateTransform(orientation: newRotation, position: newPosition, duration: animationDuration)
                            }
                        }
                    }
                }
            }
            .onEnded { _ in
                log("end drag")
                state.endGesture()
            }
    }
    
    /// Drag gesture for training only.
    private var dragTrainingGesture: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .targetedToAnyEntity()
            .onChanged { value in
                Task { @MainActor in
                    guard let globeEntity = value.entity as? GlobeEntity else { return }
                    
                    // Determine if it's the first or second globe
                    let isFirstGlobe = (globeEntity == model.firstGlobeEntity)
                    //                    let isSecondGlobe = (globeEntity == model.secondGlobeEntity)
                    guard isFirstGlobe else {
                        log("Ignoring drag gesture on secondGlobe")
                        return
                    }
                    guard globeEntity.isInMovement == false else {
                        log("Ignoring gesture due to its current movement")
                        return
                    }
                    guard !state.isScaling,
                          !state.isRotating,
                          !rotationState.isActive else {
                        log("exit drag")
                        return
                    }
                    if state.positionAtGestureStart == nil {
                        log("start drag")
                        state.isDragging = true
                        state.positionAtGestureStart = value.entity.position(relativeTo: nil)
                        state.localRotationAtGestureStart = (value.entity as? GlobeEntity)?.orientation
                        let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                        let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                        studyModel.setupNextTask(gestureType: .position, targetTransform: targetTransform)
                        studyModel.currentTask?.start(type: .position,
                                                      originalTransform: originalTransform,
                                                      targetTransform: targetTransform)
                    }
                    
                    
                    if let positionAtGestureStart = state.positionAtGestureStart,
                       let localRotationAtGestureStart = state.localRotationAtGestureStart,
                       let globeEntity = value.entity as? GlobeEntity,
                       let cameraPosition = CameraTracker.shared.position {
                        log("update drag")
                        let location3D = value.convert(value.location3D, from: .local, to: .scene)
                        let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                        let delta = location3D - startLocation3D
                        let newPosition = positionAtGestureStart + SIMD3<Float>(delta)
                        
                        // rotate the globe around a vertical axis (which is different to the globe's axis if it is not north-oriented)
                        // such that the same location is facing the camera as the globe is dragged horizontally around the camera
                        let newRotation: simd_quatf?
                        if model.rotateGlobeWhileDragging {
                            var v1 = cameraPosition - positionAtGestureStart
                            var v2 = cameraPosition - newPosition
                            v1.y = 0
                            v2.y = 0
                            v1 = normalize(v1)
                            v2 = normalize(v2)
                            let rotationSinceStart = simd_quatf(from: v1, to: v2)
                            let localRotationSinceStart = simd_quatf(value.convert(rotation: rotationSinceStart, from: .scene, to: .local))
                            newRotation = simd_mul(localRotationSinceStart, localRotationAtGestureStart)
                            
                        } else {
                            newRotation = nil
                        }
                        
                        
                        // animate the transformation to reduce jitter, as in the Apple EntityGestures sample project
                        var originalTransform = globeEntity.transform
                        
                        
                        originalTransform = globeEntity.animateTransform(orientation: newRotation,
                                                                         position: newPosition,
                                                                         duration: animationDuration)
                        guard var currentTask = studyModel.currentTask else {
                            log("Error: currentTask is nil. Cannot add action")
                            return
                        }
                        
                        let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                        
                        currentTask.addAction(StudyAction(
                            actionID: currentTask.actionID,
                            type: .position,
                            status: .drag,
                            originalTransform: originalTransform,
                            targetTransform: targetTransform))
                        
                        // This function applies transparency to second globe if it is in proximity to the first globe
                        let globesDistance = simd_distance(originalTransform.translation,targetTransform.translation)
                        
                        if let secondGlobeEntity = model.secondGlobeEntity {
                            if globesDistance < state.inProximityRange {
                                model.globesInProximity = true
                                if secondGlobeEntity.components.has(OpacityComponent.self) {
                                    secondGlobeEntity.components[OpacityComponent.self] = OpacityComponent(opacity: 0.6)
                                } else {
                                    secondGlobeEntity.components.set(OpacityComponent(opacity: 1.0))
                                }
                            } else {
                                model.globesInProximity = false
                            }
                        }
                    }
                }
            }
            .onEnded { value in
                log("end drag")
                state.endGesture()
                let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                studyModel.currentTask?.end(type: .position,
                                            originalTransform: originalTransform,
                                            targetTransform: targetTransform)

                
                guard let currentTask = studyModel.currentTask else {
                    Log.error("current task does not exist")
                    return
                }
                studyModel.currentTask?.updateAccuracyResult()
                if let firstGlobeEntity = model.firstGlobeEntity, let secondGlobeEntity = model.secondGlobeEntity {
                    if currentTask.isMatching == true {
                        studyModel.currentTask = nil
                        SoundManager.shared.playSound(named: "correct")
                        firstGlobeEntity.respawnGlobe(.left)
                        secondGlobeEntity.respawnGlobe(.right)
                    }
                }
                studyModel.currentTask = nil
            }
    }
    
    // Magnify gesture for training only
    private var magnifyTrainingGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0)
            .targetedToAnyEntity()
            .onChanged { value in
                Task { @MainActor in
                    guard let globeEntity = value.entity as? GlobeEntity
                    else { return }
                    
                    if let secondGlobeEntity = model.secondGlobeEntity {
                        
                        // Below is the setup in executing responsive secondGlobe movement to first globe scale
                        let from = globeEntity.position(relativeTo: nil)
                        let to = secondGlobeEntity.position(relativeTo: nil)
                        let rawDirection = to - from
                        let direction = length(rawDirection) == 0 ? [1, 0, 0] : normalize(rawDirection)
                        state.directionVector = direction
                        
                    }
                    
                    guard !state.isRotating, !rotationState.isActive else {
                        log("exit magnify")
                        return
                    }
                    
                    let isFirstGlobe = (globeEntity == model.firstGlobeEntity)
                    guard isFirstGlobe else {
                        log("Ignoring magnify gesture on secondGlobe")
                        return
                    }
                    guard globeEntity.isInMovement == false else {
                        log("Ignoring gesture due to its current movement")
                        return
                    }
                    
                    if !state.isScaling {
                        log("start magnify")
                        state.scaleAtGestureStart = globeEntity.meanScale
                        state.positionAtGestureStart = value.entity.position
                        // The camera position at the start of the scaling gesture is used to move the globe.
                        // Querying the position on each update would result in an unstable globe position if the camera is moved.
                        state.cameraPositionAtGestureStart = CameraTracker.shared.position
                        
                        let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                        let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                        studyModel.setupNextTask(gestureType: .scale, targetTransform: targetTransform)
                        studyModel.currentTask?.start(type: .scale,
                                                      originalTransform: originalTransform,
                                                      targetTransform: targetTransform)
                    }
                    
                    
                    if let globeScaleAtGestureStart = state.scaleAtGestureStart,
                       let globePositionAtGestureStart = state.positionAtGestureStart,
                       let cameraPositionAtGestureStart = state.cameraPositionAtGestureStart {
                        log("update magnify")
                        let scale = max(model.configuration.minScale, min(model.configuration.maxScale, Float(value.magnification) * globeScaleAtGestureStart))
                        
                        if model.moveGlobeWhileScaling {
                            globeEntity.scaleAndAdjustDistanceToCamera(
                                newScale: scale,
                                oldScale: globeScaleAtGestureStart,
                                oldPosition: globePositionAtGestureStart,
                                cameraPosition: cameraPositionAtGestureStart,
                                radius: model.globe.radius,
                                duration: animationDuration // animate the transformation to reduce jitter, as in the Apple EntityGestures sample project
                            )
                        } else {
                            globeEntity.scale = [scale, scale, scale]
                        }
                                                
                       // This function below adjusts second globe's z-axis position according to the scale of the first globe.
                       // It only applies when the study's scaling condition is in "Adjust distance to the camera when scaling"
                        if let secondGlobeEntity = model.secondGlobeEntity {
                            if model.moveGlobeWhileScaling {
                                
                                let globeOldScale = (globeEntity.scale.x + globeEntity.scale.y + globeEntity.scale.z) / 3
                                secondGlobeEntity.adjustDistanceToCamera(
                                    newScale: scale,
                                    oldScale: globeOldScale,
                                    oldPosition: secondGlobeEntity.position,
                                    cameraPosition: cameraPositionAtGestureStart,
                                    radius: model.globe.radius,
                                    duration: animationDuration // animate the transformation to reduce jitter, as in the Apple EntityGestures sample project
                                )
                            }
                        }
                        
                        // This function below adjusts second globe's position according to the scale of the first globe
                        if let secondGlobeEntity = model.secondGlobeEntity,
                           let direction = state.directionVector {
                            
                            let defaultRadius = model.globe.radius
                            let secondGlobeScale = (secondGlobeEntity.scale.x + secondGlobeEntity.scale.y + secondGlobeEntity.scale.z) / 3.0
                            let secondRadius = secondGlobeScale * defaultRadius
                            let currentRadius = scale * defaultRadius
                            let middleOffset: Float = 0.35
                            let requiredDistance = currentRadius + secondRadius + middleOffset
                            
                            let basePosition = globeEntity.position(relativeTo: nil)
                            let newSecondGlobePosition = basePosition + (direction * requiredDistance)
                            
                            
                            let currentPosition = secondGlobeEntity.position(relativeTo: nil)
                            let distanceThreshold: Float = 0.001
                            
                            if distance(currentPosition, newSecondGlobePosition) > distanceThreshold {
                                secondGlobeEntity.animateTransform(
                                    orientation: secondGlobeEntity.orientation,
                                    position: newSecondGlobePosition,
                                    duration: animationDuration
                                )
                            }
                        }
                    }
                    
                    var originalTransform = globeEntity.transform
                    
                    originalTransform = globeEntity.animateTransform(orientation: globeEntity.orientation,
                                                                     position: globeEntity.position,
                                                                     duration: animationDuration)
                    
                    guard var currentTask = studyModel.currentTask else {
                        log("Error: currentTask is nil. Cannot add action")
                        return
                    }
                    let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                    currentTask.addAction(StudyAction(
                        actionID: currentTask.actionID,
                        type: .scale,
                        status: .magnify,
                        originalTransform: originalTransform,
                        targetTransform: targetTransform))
                }
            }
            .onEnded { _ in
                state.endGesture()
                log("end magnify")
                let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                studyModel.currentTask?.end(type: .scale,
                                            originalTransform: originalTransform,
                                            targetTransform: targetTransform)
               
                studyModel.currentTask?.updateAccuracyResult()
                if let firstGlobeEntity = model.firstGlobeEntity, let secondGlobeEntity = model.secondGlobeEntity {
                    if studyModel.currentTask?.isMatching == true {
                        SoundManager.shared.playSound(named: "correct")
                        studyModel.currentTask = nil
                        firstGlobeEntity.respawnGlobe(.left)
                        secondGlobeEntity.respawnGlobe(.right)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            firstGlobeEntity.animateTransform(scale: 0.5, duration: 0.2)
                            secondGlobeEntity.animateTransform(scale: 1.5, duration: 0.2)
                        }
                    }
                }
                studyModel.currentTask = nil
            }
    }
    
    /// Two-handed rotation training gesture for training only.
    private var rotateTrainingGesture: some Gesture {
        RotateGesture3D()
            .targetedToAnyEntity()
            .onChanged { value in
                Task { @MainActor in
                    guard let globeEntity = value.entity as? GlobeEntity else { return }
                    
                    guard !state.isScaling, !rotationState.isActive else {
                        log ("exit rotate")
                        return
                    }
                    
                    let isFirstGlobe = (globeEntity == model.firstGlobeEntity)
                    guard isFirstGlobe else {
                        log("Ignoring rotate gesture on secondGlobe")
                        return
                    }
                    guard globeEntity.isInMovement == false else {
                        log("Ignoring gesture due to its current movement")
                        return
                    }
                    
                    if !state.isRotating {
                        log("start rotate")
                        state.orientationAtGestureStart = .init(value.entity.orientation(relativeTo: nil))
                        Task { @MainActor in
                            pauseRotationAndStoreRotationState()
                            let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                            let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                            studyModel.setupNextTask(gestureType: .rotation, targetTransform: targetTransform)
                            studyModel.currentTask?.start(type: .rotation,
                                                          originalTransform: originalTransform,
                                                          targetTransform: targetTransform)
                            
                        }
                    }
                    
                    
                    if let globeEntity = value.entity as? GlobeEntity,
                       let orientationAtGestureStart = state.orientationAtGestureStart {
                        log("update rotate")
                        
                        // reduce the rotation angle for enlarged globes to avoid excessively fast movements
                        let rotation = value.rotation
                        let scale = max(1, Double(globeEntity.meanScale))
                        let angle = Angle2D(radians: rotation.angle.radians / scale)
                        
                        // Flip orientation of rotation to match rotation direction of hands.
                        // Flipping code from "GestureComponent.swift" of Apple sample code project "Transforming RealityKit entities using gestures"
                        // https://developer.apple.com/documentation/realitykit/transforming-realitykit-entities-with-gestures?changes=_8
                        let flippedRotation = Rotation3D(angle: angle,
                                                         axis: RotationAxis3D(x: -rotation.axis.x,
                                                                              y: rotation.axis.y,
                                                                              z: -rotation.axis.z))
                        
                        let newOrientation = orientationAtGestureStart.rotated(by: flippedRotation)
                        globeEntity.animationPlaybackController?.stop()
                        globeEntity.orientation = simd_quatf(newOrientation)
                    }
                    
                    let currentScale = globeEntity.scale
                    let averageScale = (currentScale.x + currentScale.y + currentScale.z) / 3
                    
                    let originalTransform = globeEntity.animateTransform(scale: averageScale, orientation: globeEntity.orientation,
                                                                         position: globeEntity.position,
                                                                         duration: animationDuration)
                    
                    globeEntity.scale = SIMD3<Float>(repeating: averageScale)
                    
                    guard var currentTask = studyModel.currentTask else {
                        log("Error: currentTask is nil. Cannot add action")
                        return
                    }
                    let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                    currentTask.addAction(StudyAction(
                        actionID: currentTask.actionID,
                        type: .rotation,
                        status: .rotate,
                        originalTransform: originalTransform,
                        targetTransform: targetTransform))
                    
                }
            }
            .onEnded { value in
                log("end rotate")
                
                if let paused = state.isRotationPausedAtGestureStart {
                    model.configuration.isRotationPaused = paused
                }
                
                state.endGesture()
                let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                studyModel.currentTask?.end(type: .rotation,
                                            originalTransform: originalTransform,
                                            targetTransform: targetTransform)
                studyModel.currentTask?.updateAccuracyResult()
                if let firstGlobeEntity = model.firstGlobeEntity, let secondGlobeEntity = model.secondGlobeEntity {
                    if studyModel.currentTask?.isMatching == true {
                        SoundManager.shared.playSound(named: "correct")
                        studyModel.currentTask = nil
                        firstGlobeEntity.respawnGlobe(.leftClose)
                        secondGlobeEntity.respawnGlobe(.rightClose)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            firstGlobeEntity.animateTransform(orientation: simd_quatf(angle: 6 * Float.pi, axis: SIMD3<Float>(1, 1, 0)), duration: 0.1)
                        }
                    }
                }
                studyModel.currentTask = nil
            }
    }
        
    /// One-handed training gesture to rotate globe for training only.
    private var rotateGlobeAxisTrainingGesture: some Gesture {
        LongPressGesture(minimumDuration: minimumLongPressDuration)
            .sequenced(before: DragGesture(minimumDistance: 0.0))
            .targetedToAnyEntity()
            .updating($rotationState) { value, rotationState, _ in
                guard let entity = value.entity as? GlobeEntity else { return }

                switch value.gestureValue {
                    // Long press begins.
                case .first(true):
                    rotationState = .pressing
                    
                    // Long press confirmed, dragging may begin.
                case .second(true, let drag):
                    
                    let isFirstGlobe = (entity == model.firstGlobeEntity)
                    
                    guard isFirstGlobe else {
                        log("Ignoring magnify gesture on secondGlobe")
                        return
                    }
                    guard entity.isInMovement == false else {
                        log("Ignoring gesture due to its current movement")
                        return
                    }
                    Task{
                        if isInRotatingState == false {
                            let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                            let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                            studyModel.setupNextTask(gestureType: .rotation, targetTransform: targetTransform)
                            studyModel.currentTask?.start(type: .rotation,
                                                          originalTransform: originalTransform,
                                                          targetTransform: targetTransform)
                            isInRotatingState = true
                        }
                    }
                    Task { @MainActor in
                        pauseRotationAndStoreRotationState()
                    }
                    
                    guard let drag = drag else { return }
                    
                    
                    Task { @MainActor in

                        if state.orientationAtGestureStart == nil {
                            state.orientationAtGestureStart = Rotation3D(entity.orientation)
                        }
                        
                        if let globeEntity = value.entity as? GlobeEntity,
                           let orientationAtGestureStart = state.orientationAtGestureStart {
                            log("update rotate")
                            
                            let dragTranslation = drag.translation
                            
                            // reduce the rotation angle for enlarged globes to avoid excessively fast movements
                            //                            let rotation = value.rotation
                            let scale = max(1, Float(globeEntity.meanScale) * model.globe.radius)
                            let angleX = Angle2D(radians: Double(Float(dragTranslation.height) * rotationSpeed / scale))
                            let angleY = Angle2D(radians: Double(Float(dragTranslation.width) * rotationSpeed / scale))
                            
                            // Originally it flips orientation of rotation to match rotation direction of hands, for two-handed.
                            // Flipping code from "GestureComponent.swift" of Apple sample code project "Transforming RealityKit entities using gestures"
                            // https://developer.apple.com/documentation/realitykit/transforming-realitykit-entities-with-gestures?changes=_8
                            let rotationX = Rotation3D(angle: angleY, axis: RotationAxis3D(x: 0, y: 1, z: 0))
                            let rotationY = Rotation3D(angle: angleX, axis: RotationAxis3D(x: 1, y: 0, z: 0))
                            
                            let newOrientation = orientationAtGestureStart
                                .rotated(by: rotationX)
                                .rotated(by: rotationY)
                            
                            // Apply the rotation to the globe
                            globeEntity.animationPlaybackController?.stop()
                            globeEntity.orientation = simd_quatf(newOrientation)
                            
                            let currentScale = globeEntity.scale
                            let averageScale = (currentScale.x + currentScale.y + currentScale.z) / 3
                            
                            
                            let originalTransform = globeEntity.animateTransform(scale: averageScale,
                                                                                 orientation: globeEntity.orientation,
                                                                                 position: globeEntity.position,
                                                                                 duration: animationDuration)
                            
                            globeEntity.scale = SIMD3<Float>(repeating: averageScale)
                            
                            guard var currentTask = studyModel.currentTask else {
                                log("Error: currentTask is nil. Cannot add action")
                                return
                            }
                            let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                            currentTask.addAction(StudyAction(
                                actionID: currentTask.actionID,
                                type: .rotation,
                                status: .rotate,
                                originalTransform: originalTransform,
                                targetTransform: targetTransform))
                        }
                    }
                    
                default:
                    rotationState = .inactive
                }
            }
            .onEnded { value in
                isInRotatingState = false
                switch value.gestureValue {
                case .second(true, _):
                    // Reset the previous rotation state
                    if let paused = state.isRotationPausedAtGestureStart {
                        model.configuration.isRotationPaused = paused
                    }
                                
                    state.endGesture()
                    let originalTransform = model.firstGlobeEntity?.transform ?? Transform.identity
                    let targetTransform = model.secondGlobeEntity?.transform ?? Transform.identity
                    studyModel.currentTask?.end(type: .rotation,
                                                originalTransform: originalTransform,
                                                targetTransform: targetTransform)
       
                    studyModel.currentTask?.updateAccuracyResult()
                    if let firstGlobeEntity = model.firstGlobeEntity, let secondGlobeEntity = model.secondGlobeEntity {
                        if studyModel.currentTask?.isMatching == true {
                            SoundManager.shared.playSound(named: "correct")
                            studyModel.currentTask = nil
                            firstGlobeEntity.respawnGlobe(.leftClose)
                            secondGlobeEntity.respawnGlobe(.rightClose)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                firstGlobeEntity.animateTransform(orientation: simd_quatf(angle: 6 * Float.pi, axis: SIMD3<Float>(1, 1, 0)), duration: 0.1)
                            }
                        }
                    }
                    studyModel.currentTask = nil
                    
                default:
                    break
                }
            }
    }
    
    /// Pauses automatic rotation of the globe while the globe is rotated by a gesture, and stores the automatic rotation state.
    private func pauseRotationAndStoreRotationState() {
        if state.isRotationPausedAtGestureStart == nil {
            state.isRotationPausedAtGestureStart = model.configuration.isRotationPaused
            model.configuration.isRotationPaused = true
        }
    }
    
    func computeReferenceRotation(for entity: Entity) -> simd_quatf? {
        guard let cameraPosition = CameraTracker.shared.position else { return nil }
        
        // Compute forward vector from globe to camera
        var forwardVector = cameraPosition - entity.position
        forwardVector.y = 0  // Keep movement in the horizontal plane
        forwardVector = normalize(forwardVector)
        
        // Compute right vector (X-axis) perpendicular to the forward vector
        let upVector = SIMD3<Float>(0, 1, 0) // World up direction
        let rightVector = normalize(cross(upVector, forwardVector))
        
        // Create rotation to align X-axis to rightVector and Z-axis to forwardVector
        let referenceRotation = simd_quatf(from: [1, 0, 0], to: rightVector) *
        simd_quatf(from: [0, 0, 1], to: forwardVector)
        
        return referenceRotation
    }
    
    private func log(_ message: String) {
#if DEBUG
        //        let logger = Logger(subsystem: "Globe Gestures", category: "Gestures")
        //        logger.info("\(message)")
#endif
    }
}
