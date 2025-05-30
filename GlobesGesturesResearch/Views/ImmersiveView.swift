//
//  ImmersiveView.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 14/8/2024.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(ViewModel.self) private var model
    @Environment(StudyModel.self) private var studyModel
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        RealityView { content, attachments in // async on MainActor
            // Important: @State properties initialized in this closure are not available
            // on the first call of the update closure (optionals will still be nil).
            // Therefore do not defer initialization of entities to the update closure.
            
            let root = Entity()
            root.name = "Globes"
            content.add(root)
            
            // initialize the globes
            updateGlobeEntity(to: content, attachments: attachments)
        } update: { content, attachments in // synchronous on MainActor
            updateGlobeEntity(to: content, attachments: attachments)
        } attachments: { // synchronous on MainActor
            Attachment(id: ViewModel.AttachmentView.position.rawValue) {
                PositionOptionsAttachmentView()
                    .fixedSize()
                    .glassBackgroundEffect()
            }
            Attachment(id: ViewModel.AttachmentView.rotation.rawValue) {
                RotationOptionsAttachmentView()
                    .fixedSize()
                    .glassBackgroundEffect()
            }
            Attachment(id: ViewModel.AttachmentView.scale.rawValue) {
                ScaleOptionsAttachmentView()
                    .fixedSize()
                    .glassBackgroundEffect()
            }
            Attachment(id: ViewModel.AttachmentView.all.rawValue) {
                GestureCombinationAttachmentView()
                    .fixedSize()
                    .glassBackgroundEffect()
            }
        }
        .onAppear {
            model.immersiveSpaceState = .open
        }
        .onDisappear {
            model.immersiveSpaceState = .closed
        }
        .globeGestures(model: model, studyModel: studyModel)
    }
    
    @MainActor
    /// Subscribe to entity-add events to setup entities.
    ///
    /// Starting the animation and setting up IBL are only possible after the immersive space has been created and all required entities have been added.
    /// - Parameter event: The event.
    private func handleDidAddEntity(_ event: SceneEvents.DidAddEntity) {
        if let globeEntity = event.entity as? GlobeEntity {
            animateMoveIn(of: globeEntity)
        }
    }
    
    @MainActor
    /// Move-in animation that changes the position and the scale of a globe.
    /// - Parameter entity: The globe entity.
    private func animateMoveIn(of entity: Entity) {
        if let globeEntity = entity as? GlobeEntity {
            let targetPosition = model.configuration.positionRelativeToCamera(distanceToGlobe: 0.5)
            
            globeEntity.animateTransform(scale: 1, position: targetPosition)
        }
    }
    
    @MainActor
    /// Add a new globe entity or remove a globe entity, and update the attachment view.
    /// - Parameters:
    ///   - content: Root of scene content.
    ///   - attachments: The attachments views.
    private func updateGlobeEntity(
        to content: RealityViewContent,
        attachments: RealityViewAttachments
    ) {
        guard let root = content.entities.first?.findEntity(named: "Globes") else { return }
        root.children
            .filter { $0 is GlobeEntity }
            .forEach { $0.removeFromParent() }

        if let firstGlobeEntity = model.firstGlobeEntity {
            root.addChild(firstGlobeEntity)
        }
        if let secondGlobeEntity = model.secondGlobeEntity {
            root.addChild(secondGlobeEntity)
        }
             
        // update attachments
        addAttachments(attachments)
    }
    
    @MainActor
    private func addAttachments(_ attachments: RealityViewAttachments) {
        guard let globeEntity = model.firstGlobeEntity else { return }
        
        // remove all previous attachment views
        for viewAttachmentEntity in globeEntity.children where viewAttachmentEntity is ViewAttachmentEntity {
            globeEntity.removeChild(viewAttachmentEntity)
        }
        
        switch model.attachmentView {
        case .position, .rotation, .scale:
            if let attachmentEntity = attachments.entity(for: model.attachmentView!.rawValue) {
                attachmentEntity.components.set(SphereLabelComponent(radius: model.globe.radius, offset: 0.1))
                globeEntity.addChild(attachmentEntity)
            }
        case .all:
            if let attachmentEntity = attachments.entity(for: model.attachmentView!.rawValue) {
                attachmentEntity.components.set(SphereLabelComponent(radius: model.globe.radius, offset: 0.25))
                globeEntity.addChild(attachmentEntity)
            }
        case .none:
            break
        }
    }
}
