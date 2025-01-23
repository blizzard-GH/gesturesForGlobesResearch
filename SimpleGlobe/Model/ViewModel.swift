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
@Observable class ViewModel: CustomDebugStringConvertible {
    
    /// Shared singleton that can be accessed by the AppDelegate.
    @MainActor
    static let shared = ViewModel()
    
    @MainActor
    let globe = Globe(
        name: "Bellerby World Globe",
        shortName: "World Globe",
        nameTranslated: nil,
        authorSurname: "Peter",
        authorFirstName: "Bellerby",
        date: "2023",
        description: "Peter Bellerby makes modern globes with old world craftsmanship. Many consider him the finest living globe maker.",
        infoURL: URL(string: "https://www.davidrumsey.com/luna/servlet/s/cd8p41"),
        radius: 0.325,
        texture: "Bellerby65cmSchminkeGagarin"
    )
    
    @MainActor
    let secondGlobe = Globe(
        name: "Second Globe",
        shortName: "Target Globe",
        nameTranslated: nil,
        authorSurname: "None",
        authorFirstName: "None",
        date: "None",
        description: "This is a target globe.",
        infoURL: URL(string: "https://www.solarsystemscope.com/textures/"),
        radius: 0.325,
        texture: "Bellerby65cmSchminkeGagarin"
    )
    
    // MARK: - Gestures Configuration
    
    /// Rotate the globe while it is being dragged such that the same geographic location is continuously facing the camera
    @MainActor
    var rotateGlobeWhileDragging = true
    
    // MARK: - Attachment Views
    @MainActor
    var showPositionOptionsAttachmentView: Bool = true
    
    
    // MARK: - Visible Globes
    
    @MainActor
    /// A `Configuration` stores dynamic properties of a globe, such as the rotation, the loading status, whether an attachment is visible, etc.
    var configuration: GlobeConfiguration
   
    @MainActor
    /// After a globe is loaded, a `GlobeEntity` is initialized. SwiftUI observes this object and synchronises the content of the `ImmersiveView` (a `RealityView`)`.
    var globeEntity: GlobeEntity?
    var secondGlobeEntity: GlobeEntity?        
    
    @MainActor
    init() {
        self.configuration = GlobeConfiguration(
            globe: globe,
            speed: GlobeConfiguration.defaultRotationSpeed,
            isRotationPaused: true
        )
        
        do {
            // Load grid with ISO 3166-1 numeric-3 country codes from Natural Earth 1:110 million.
            // https://en.wikipedia.org/wiki/ISO_3166-1_numeric
            self.georeferencer = try Georeferencer(fileName: "ISO 3166-1 numeric-3", columns: 2048, rows: 1024)
            
            // Attribute table with ISO 3166-1 numeric-3 key and string attribute.
            self.attributeTable = try AttributeTable(fileName: "geo")
        } catch {
            errorToShowInAlert = error
            self.georeferencer = nil
            self.attributeTable = nil
        }
    }
    
    @MainActor
    /// Open an immersive space if there is none and show a globe. Once loaded, the globe fades in.
    /// - Parameters:
    ///   - globe: The globe to show.
    ///   - selection: When selection is not `none`, the texture is replaced periodically with a texture of one of the globes in the selection.
    ///   - openImmersiveSpaceAction: Action for opening an immersive space.
    func load(
        firstGlobe: Globe,
        secondGlobe: Globe,
        openImmersiveSpaceAction: OpenImmersiveSpaceAction
    ) {
        configuration.isLoading = true
        configuration.isVisible = false
        configuration.showAttachment = false
        
//        Task {
//            openImmersiveGlobeSpace(openImmersiveSpaceAction)            
//            let globeEntity = try await GlobeEntity(globe: globe)
//            Task { @MainActor in
////                ViewModel.shared.storeGlobeEntity(globeEntity)
//                self.storeGlobeEntity(globeEntity, globe: globe)
//            }
//        }
        Task {
                openImmersiveGlobeSpace(openImmersiveSpaceAction)
                
                async let firstGlobeEntity = GlobeEntity(globe: firstGlobe)
                async let secondGlobeEntity = GlobeEntity(globe: secondGlobe)
                
                do {
                    let entities = try await (firstGlobeEntity, secondGlobeEntity)
                    Task { @MainActor in
                        storeGlobeEntity(entities.0, entities.1)
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
//    func storeGlobeEntity(_ globeEntity: GlobeEntity, globe: Globe) {
    func storeGlobeEntity(_ firstEntity: GlobeEntity, _ secondEntity: GlobeEntity) {
//        if globe == self.globe {
//            self.globeEntity = globeEntity
//        } else {
//            self.secondGlobeEntity = globeEntity
//        }
        // Configure and position first globe
//        firstEntity.scale = [0.01, 0.01, 0.01]
        firstEntity.position = configuration.positionRelativeToCamera(distanceToGlobe: 0.5, xOffset: -0.5)
        
        // Configure and position second globe
//        secondEntity.scale = [0.01, 0.01, 0.01]
        secondEntity.position = configuration.positionRelativeToCamera(distanceToGlobe: 0.5, xOffset: 0.5)
        
        if secondEntity.components.has(OpacityComponent.self) {
            secondEntity.components[OpacityComponent.self] = OpacityComponent(opacity: 0.5)
        } else {
            secondEntity.components.set(OpacityComponent(opacity: 0.5))
        }
        
        globeEntity = firstEntity
        secondGlobeEntity = secondEntity
        configuration.isLoading = false
        configuration.isVisible = true
        
        // Set the initial scale and position for a move-in animation.
        // The animation is started by a DidAddEntity event when the immersive space has been created and the globe has been added to the scene.
//        globeEntity.scale = [0.01, 0.01, 0.01]
//        globeEntity.position = configuration.positionRelativeToCamera(distanceToGlobe: 2)
        
        // Rotate the central meridian to the camera, to avoid showing the empty hemisphere on the backside of some globes.
        // The central meridian is at [-1, 0, 0], because the texture u-coordinate with lon = -180° starts at the x-axis.
//        if let viewDirection = CameraTracker.shared.viewDirection {
//            var orientation = simd_quatf(from: [-1, 0, 0], to: -viewDirection)
//            orientation = GlobeEntity.orientToNorth(orientation: globeEntity.orientation)
//            globeEntity.orientation = orientation
//        }
        
        // store the globe entity
//        self.globeEntity = globeEntity
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
    func hideGlobe() {
        let duration = 0.666
        
        // shrink the globe
        globeEntity?.scaleAndAdjustDistanceToCamera(
                newScale: 0.001, // scaling to 0 spins the globe, so scale to a value slightly greater than 0
                radius: globe.radius,
                duration: duration
            )
        secondGlobeEntity?.scaleAndAdjustDistanceToCamera(newScale: 0.001, radius: secondGlobe.radius, duration: duration)
        
        configuration.isVisible = false
        configuration.showAttachment = false
    }
    
    // MARK: - Immersive Space
    
    @MainActor
    var immersiveSpaceIsShown = false

    @MainActor
    private func openImmersiveGlobeSpace(_ action: OpenImmersiveSpaceAction) {
        guard !immersiveSpaceIsShown else { return }
        Task {
            let result = await action(id: "ImmersiveGlobeSpace")
            switch result {
            case .opened:                
                Task { @MainActor in
                    immersiveSpaceIsShown = true
                }
            case .error:
                Task { @MainActor in
                    errorToShowInAlert = error("A globe could not be shown.")
                }
                fallthrough
            case .userCancelled:
                fallthrough
            @unknown default:
                Task { @MainActor in
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
    
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
    
    // MARK: - Location to Attribute
    
    @MainActor
    var georeferencer: Georeferencer?
    
    @MainActor
    var attributeTable: AttributeTable?
    
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
        
        description += "Immersive space is shown: \(immersiveSpaceIsShown)\n"
        
        // globes
        description += "Globe configuration: \(globe.name), rotating: \(!configuration.isRotationPaused)\n"
        if let globeEntity {
            description += ", pos=\(globeEntity.position.x),\(globeEntity.position.y),\(globeEntity.position.z)"
            description += ", scale=\(globeEntity.scale.x),\(globeEntity.scale.y),\(globeEntity.scale.z)"
        }
        description += "\n"
        
        // error handling
        if let errorToShowInAlert {
            description += "Error to show: \(errorToShowInAlert.localizedDescription)\n"
        }
        
        return description
    }
}
