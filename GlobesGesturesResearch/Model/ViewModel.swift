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
class ViewModel {
    
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
        authorFirstName: "Natural Earth",
        date: "2025",
        description: "Natural Earth 8K version.",
        infoURL: URL(string: "https://shadedrelief.com/ne-draft/"),
        radius: 0.325,
        texture: "NE1_HR_SR_OB_DR_8k"
    )
    
    @MainActor
    let secondGlobe = Globe(
        name: "Target Globe",
        shortName: "Target Globe",
        nameTranslated: nil,
        authorSurname: "None",
        authorFirstName: "Natural Earth 8K version with Black and White layer",
        date: "20245",
        description: "This is a target globe used for gestures research.",
        infoURL: URL(string: "https://shadedrelief.com/ne-draft/"),
        radius: 0.325,
        texture: "NE1_HR_SR_OB_DR_8k_MC"
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
    func load(firstGlobe: Globe, secondGlobe: Globe, openImmersiveSpaceAction: OpenImmersiveSpaceAction) async {        
        do {
            async let globeEntity1 = GlobeEntity(globe: firstGlobe)
            async let globeEntity2 = GlobeEntity(globe: secondGlobe)
            let entities = try await (globeEntity1, globeEntity2)
            
            entities.0.position = configuration.positionRelativeToCamera(distanceToGlobe: 0.5, xOffset: -0.5)
            entities.1.position = configuration.positionRelativeToCamera(distanceToGlobe: 0.5, xOffset: 0.5)
            
            entities.0.respawnGlobe(.left)
            entities.1.respawnGlobe(.right)
            
            firstGlobeEntity = entities.0
            secondGlobeEntity = entities.1
        } catch {
            errorToShowInAlert = error
        }
    }
    
    @MainActor
    /// Open an immersive space if there is none and show a globe. Once loaded, the globe fades in.
    /// - Parameters:
    ///   - globe: The globe to show.
    ///   - openImmersiveSpaceAction: Action for opening an immersive space.
    func load(globe: Globe, openImmersiveSpaceAction: OpenImmersiveSpaceAction) async {
        do {
            firstGlobeEntity = try await GlobeEntity(globe: globe)
            firstGlobeEntity?.position = configuration.positionRelativeToCamera(distanceToGlobe: 0.5, xOffset: -0.5)
            firstGlobeEntity?.respawnGlobe(.right)
        } catch {
            errorToShowInAlert = error
        }
    }
    
    @MainActor
    /// Remove the globes from the scene.
    /// - Parameter id: Globe ID
    func removeGlobes() {
        firstGlobeEntity = nil
        secondGlobeEntity = nil
    }
    
    // MARK: - Immersive Space
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    @MainActor
    func openImmersiveSpace(_ openImmersiveSpaceAction: OpenImmersiveSpaceAction) async {
        guard immersiveSpaceState == .closed else { return }
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
            errorToShowInAlert = error("A globe could not be shown.")
            fallthrough
        @unknown default:
            // On unknown response, assume space did not open.
            immersiveSpaceState = .closed
        }
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
    
    // MARK: - Gestures
    @MainActor
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
        let modalityList: [RotationCondition.RotationGestureModality]
        modalityList = RotationCondition.rotationConditionsGetter(for: rotationConditions,
                                                                  lastUsedIndex: RotationCondition.lastUsedRotationConditionIndex).0
        switch currentPage {
        case .rotationTraining1, .rotationExperiment1, .confirmationPageRotation1, .rotationExperimentForm1:
            if modalityList[0] == .oneHanded{
                oneHandedRotationGesture = true
            } else {
                oneHandedRotationGesture = false
            }
        case .rotationTraining2, .rotationExperiment2, .confirmationPageRotation2, .rotationExperimentForm2:
            if modalityList[1] == .twoHanded{
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

