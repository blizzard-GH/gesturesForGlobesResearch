//
//  ViewModel.swift
//  Globes
//
//  Created by Bernhard Jenny on 15/3/2024.
//

import os
import RealityKit
import SwiftUI

/// A singleton model that can be accessed via `ViewModel.shared`, for example, by the app delegate. For SwiftUI, use the new Observable framework instead of accessing the shared singleton.
///
/// The `Globe` struct is a static description of a globe containing all metadata and a texture name.
///
/// A `Configuration` stores dynamic properties of a globe, such as the rotation, the loading status, whether an attachment is visible, etc.
///
/// After a globe is loaded, a `GlobeEntity` is initialized. SwiftUI observes this object and synchronises the content of the `ImmersiveView` (a `RealityView`)`.
///
///
/// For the new Observable framework: https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro
@Observable
class ViewModel: CustomDebugStringConvertible {
    
    /// Shared singleton that can be accessed by the AppDelegate.
    @MainActor
    static let shared = ViewModel()
    
    static let windowID = "Second Window"
    
    @MainActor
    let globe = Globe(
        name: "Main Globe",
        shortName: "Main Globe",
        nameTranslated: nil,
        authorSurname: "None",
        authorFirstName: "None",
        date: "2025",
        description: "This is the main globe used for gestures research.",
        infoURL: URL(string: "https://www.solarsystemscope.com/textures/"),
        radius: 0.325,
        texture: "NE1_HR_SR_OB_DR_8k"
    )
    
    @MainActor
    let secondGlobe = Globe(
        name: "Second Globe",
        shortName: "Target Globe",
        nameTranslated: nil,
        authorSurname: "None",
        authorFirstName: "None",
        date: "2024",
        description: "This is a target globe.",
        infoURL: URL(string: "https://www.solarsystemscope.com/textures/"),
        radius: 0.325,
        texture: "EarthBW"
    )
    
    var positionConditions: [PositionCondition] = []
    var rotationConditions: [RotationCondition] = []
    var scaleConditions : [ScaleCondition] = []
    
    // MARK: - Gestures Configuration
    
    /// Rotate the globe while it is being dragged such that the same geographic location is continuously facing the camera.
    @MainActor
    var rotateGlobeWhileDragging = true
    
    /// Using one-handed or two-handed gesture to rotate the globe.
    @MainActor
    var oneHandedRotationGesture = true
    
    /// Move the globe towards the camera or away from the camera while it is scaled.
    @MainActor
    var moveGlobeWhileScaling = true
    
    // MARK: - Attachment Views
    
    enum AttachmentView: String {
        case position
        case rotation
        case scale
        case all
    }
    
    /// Show an attachment view with options for positioning or scaling globes
    @MainActor
    var attachmentView: AttachmentView? = .none
    
    @MainActor
    var globesInProximity: Bool = false
    
    @MainActor
    func updateAttachmentView(for page: Page) {
        func setAttachmentView(_ attachmentView: AttachmentView) {
            if self.attachmentView != attachmentView {
                self.attachmentView = attachmentView
            }
        }
        switch page {
        case .positionComparison:
            setAttachmentView(.position)
        case .rotationComparison:
            setAttachmentView(.rotation)
        case .scaleComparison:
            setAttachmentView(.scale)
        case .outroForm:
            setAttachmentView(.all)
        default:
            attachmentView = .none
        }
    }
    
    // MARK: - Visible Globes
    
    @MainActor
    /// A `Configuration` stores dynamic properties of a globe, such as the rotation, the loading status, whether an attachment is visible, etc.
    var configuration: GlobeConfiguration
    
    @MainActor
    /// After a globe is loaded, a `GlobeEntity` is initialized. SwiftUI observes this object and synchronises the content of the `ImmersiveView` (a `RealityView`)`.
    var firstGlobeEntity: GlobeEntity?
    var secondGlobeEntity: GlobeEntity?
    
    @MainActor
    init() {
        self.configuration = GlobeConfiguration(
            globe: globe,
            speed: GlobeConfiguration.defaultRotationSpeed,
            isRotationPaused: true
        )
        loadGestureConditions()
    }
    
    @MainActor
    /// Open an immersive space if there is none and show a globe. Once loaded, the globe fades in.
    /// - Parameters:
    ///   - globe: The globe to show.
    ///   - selection: When selection is not `none`, the texture is replaced periodically with a texture of one of the globes in the selection.
    ///   - openImmersiveSpaceAction: Action for opening an immersive space.
    func load(firstGlobe: Globe, secondGlobe: Globe, openImmersiveSpaceAction: OpenImmersiveSpaceAction) {
        guard immersiveSpaceState == .closed else { return }
        
        Task {
            await openImmersiveGlobeSpace(openImmersiveSpaceAction)
            
            async let firstGlobeEntity = GlobeEntity(globe: firstGlobe)
            async let secondGlobeEntity = GlobeEntity(globe: secondGlobe)
            
            do {
                let entities = try await (firstGlobeEntity, secondGlobeEntity)
                Task { @MainActor in
                    storeGlobeEntities(entities.0, entities.1)
                    
                    entities.0.respawnGlobe(.left)
                    entities.1.respawnGlobe(.right)
                }
            } catch {
                Task { @MainActor in
                    loadingGlobeFailed(id: nil)
                }
            }
        }
    }
    
    @MainActor
    /// Open an immersive space if there is none and show a globe. Once loaded, the globe fades in.
    /// - Parameters:
    ///   - globe: The globe to show.
    ///   - openImmersiveSpaceAction: Action for opening an immersive space.
    func loadSingleGlobe(globe: Globe, openImmersiveSpaceAction: OpenImmersiveSpaceAction) {
        guard immersiveSpaceState == .closed else { return }

        Task {
            await openImmersiveGlobeSpace(openImmersiveSpaceAction)
            
            async let firstGlobeEntity = GlobeEntity(globe: globe)
            
            do {
                let entities = try await (firstGlobeEntity)
                Task { @MainActor in
                    storeSingleGlobeEntity(entities)
                    
                    entities.respawnGlobe(.right)
                }
            } catch {
                Task { @MainActor in
                    loadingGlobeFailed(id: nil)
                }
            }
        }
    }
    
    @MainActor
    /// Called after a  globe entity has been loaded.
    /// - Parameter globeEntity: The globe entity to add.
    func storeGlobeEntities(_ firstEntity: GlobeEntity, _ secondEntity: GlobeEntity) {
        // Configure and position first globe
        firstEntity.position = configuration.positionRelativeToCamera(distanceToGlobe: 0.5, xOffset: -0.5)
        
        // Configure and position second globe
        secondEntity.position = configuration.positionRelativeToCamera(distanceToGlobe: 0.5, xOffset: 0.5)
        
        firstGlobeEntity = firstEntity
        secondGlobeEntity = secondEntity
    }
    
    @MainActor
    /// Called after a  globe entity has been loaded.
    /// - Parameter globeEntity: The globe entity to add.
    func storeSingleGlobeEntity(_ firstEntity: GlobeEntity) {
        firstEntity.position = configuration.positionRelativeToCamera(distanceToGlobe: 0.5, xOffset: -0.5)
                
        firstGlobeEntity = firstEntity
    }
    
    @MainActor
    /// A new globe entity could not be loaded.
    /// - Parameters:
    ///   - id: The id of the globe that could not be loaded.
    func loadingGlobeFailed(id: Globe.ID?) {
        errorToShowInAlert = error("There is not enough memory to show another globe.",
                                   secondaryMessage: "First hide a visible globe, then select this globe again.")
    }
    
    @MainActor
    /// Hide a globe. The globe shrinks down.
    /// - Parameter id: Globe ID
    func hideGlobes(dismissImmersiveSpaceAction: DismissImmersiveSpaceAction) {
        let duration = 0.666
        
        // shrink the globe
        firstGlobeEntity?.scaleAndAdjustDistanceToCamera(
            newScale: 0.001, // scaling to 0 spins the globe, so scale to a value slightly greater than 0
            radius: globe.radius,
            duration: duration
        )
        secondGlobeEntity?.scaleAndAdjustDistanceToCamera(
            newScale: 0.001,
            radius: secondGlobe.radius,
            duration: duration)
                
        Task {
#warning("Is this correct?")
            try? await Task.sleep(for: .seconds(duration))
            await closeImmersiveGlobeSpace(dismissImmersiveSpaceAction)
        }
    }
    
    // MARK: - Immersive Space
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    @MainActor
    private func openImmersiveGlobeSpace(_ openImmersiveSpaceAction: OpenImmersiveSpaceAction) async {
        guard immersiveSpaceState != .open,
              immersiveSpaceState != .inTransition else {
            return
        }
        let result = await openImmersiveSpaceAction(id: "ImmersiveGlobeSpace")
        switch result {
        case .opened:
            // Don't set immersiveSpaceState to .open because there
            // may be multiple paths to ImmersiveView.onAppear().
            // Only set .open in ImmersiveView.onAppear().
            break
        case .userCancelled:
            immersiveSpaceState = .closed
        case .error:
            Task { @MainActor in
                errorToShowInAlert = error("A globe could not be shown.")
            }
            fallthrough
        @unknown default:
            // On unknown response, assume space did not open.
            immersiveSpaceState = .closed
        }
    }
    
    @MainActor
    func closeImmersiveGlobeSpace(_ dismissImmersiveSpaceAction: DismissImmersiveSpaceAction) async {
        guard immersiveSpaceState == .open else { return }
        await dismissImmersiveSpaceAction()
        immersiveSpaceState = .closed
        firstGlobeEntity = nil
        secondGlobeEntity = nil
    }
    
    // MARK: - Error Handling
    
    /// Error to show in an alert dialog.
    @MainActor
    var errorToShowInAlert: Error? = nil {
        didSet {
            if let errorToShowInAlert {
                let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Globes Error")
                logger.error("Alert: \(errorToShowInAlert.localizedDescription) \(errorToShowInAlert.alertSecondaryMessage ?? "")")
            }
        }
    }
    
    // MARK: - Debug Description
    
    @MainActor
    var debugDescription: String {
        var description = "\(ViewModel.self)\n"
        
        // Memory
        let availableProcMemory = os_proc_available_memory()
        description += "Available memory: \(availableProcMemory / 1024 / 1024) MB\n"
        
        // Metal memory
        if let defaultDevice = MTLCreateSystemDefaultDevice () {
            let workingSet = defaultDevice.recommendedMaxWorkingSetSize
            if workingSet > 0 {
                let currentUse = defaultDevice.currentAllocatedSize
                description += "Allocated GPU memory: \(100 * UInt64(currentUse) / workingSet)%, \(currentUse / 1024 / 1024) MB of \(workingSet / 1024 / 1024) MB\n"
            }
        }
        
        description += "Immersive space state: \(immersiveSpaceState)\n"
        
        // globes
        description += "Globe configuration: \(globe.name), rotating: \(!configuration.isRotationPaused)\n"
        if let firstGlobeEntity {
            description += ", pos=\(firstGlobeEntity.position.x),\(firstGlobeEntity.position.y),\(firstGlobeEntity.position.z)"
            description += ", scale=\(firstGlobeEntity.scale.x),\(firstGlobeEntity.scale.y),\(firstGlobeEntity.scale.z)"
        }
        description += "\n"
        
        // error handling
        if let errorToShowInAlert {
            description += "Error to show: \(errorToShowInAlert.localizedDescription)\n"
        }
        
        return description
    }
    
    // MARK: - Gestures
    
    func loadGestureConditions() {
        do {
            positionConditions = try PositionCondition.loadPositionConditions()
            rotationConditions = try RotationCondition.loadRotationConditions()
            scaleConditions = try ScaleCondition.loadScaleConditions()
        } catch let err {
            Task { @MainActor in
                errorToShowInAlert = error("Failed to load gesture conditions: \(err.localizedDescription).")
            }
        }
    }
    
    @MainActor
    func updatePositionConditions(currentPage: Page) {
        let rotatingGlobeList: [PositionCondition.PositioningGesture]
        rotatingGlobeList = PositionCondition.positionConditionsGetter(for: positionConditions,
                                                                   lastUsedIndex: PositionCondition.lastUsedPositionConditionIndex).0
        switch currentPage {
        case .positionExperiment1, .confirmationPagePosition1, .positionExperimentForm1:
            if rotatingGlobeList[0] == .notRotating{
                rotateGlobeWhileDragging = false
            } else {
                rotateGlobeWhileDragging = true
            }
        case .positionExperiment2, .confirmationPagePosition2, .positionExperimentForm2:
            if rotatingGlobeList[1] == .rotating{
                rotateGlobeWhileDragging = true
            } else {
                rotateGlobeWhileDragging = false
            }
        default:
            rotateGlobeWhileDragging = false
        }
    }
    
    @MainActor
    func updateRotationConditions(currentPage: Page) {
        let modalitylist: [RotationCondition.RotationGestureModality]
        modalitylist = RotationCondition.rotationConditionsGetter(for: rotationConditions,
                                                              lastUsedIndex: RotationCondition.lastUsedRotationConditionIndex).0
        switch currentPage {
        case .rotationTraining1, .rotationExperiment1, .confirmationPageRotation1, .rotationExperimentForm1:
            if modalitylist[0] == .oneHanded{
                oneHandedRotationGesture = true
            } else {
                oneHandedRotationGesture = false
            }
        case .rotationTraining2, .rotationExperiment2, .confirmationPageRotation2, .rotationExperimentForm2:
            if modalitylist[1] == .twoHanded{
                oneHandedRotationGesture = false
            } else {
                oneHandedRotationGesture = true
            }
        default:
            oneHandedRotationGesture = true
        }
    }
    
    @MainActor
    func updateScaleConditions(currentPage: Page) {
        let movingGlobeList: [ScaleCondition.ScalingGesture]
        movingGlobeList = ScaleCondition.scaleConditionsGetter(for: scaleConditions,
                                                                   lastUsedIndex: ScaleCondition.lastUsedScaleConditionIndex).0
        switch currentPage {
        case .scaleExperiment1, .confirmationPageScale1, .scaleExperimentForm1:
            if movingGlobeList[0] == .notMoving{
                moveGlobeWhileScaling = false
            } else {
                moveGlobeWhileScaling = true
            }
        case .scaleExperiment2, .confirmationPageScale2, .scaleExperimentForm2:
            if movingGlobeList[1] == .moving{
                moveGlobeWhileScaling = true
            } else {
                moveGlobeWhileScaling = false
            }
        default:
            moveGlobeWhileScaling = false
        }
    }
}

