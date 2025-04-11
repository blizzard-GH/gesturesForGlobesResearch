//
//  SphereLabelSystem.swift
//  GlobesGesturesResearch
//
//  Created by Bernhard Jenny on 1/4/2025.
//

import SwiftUI
import RealityKit

struct SphereLabelComponent: Component {
    let radius: Float
    let offset: Float
}

@MainActor
struct SphereLabelSystem: System {
    static let query = EntityQuery(where: .has(SphereLabelComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        guard let cameraPosition = CameraTracker.shared.position else { return }
        
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let globeEntity = entity.parent,
                  let sphereLabelComponent = entity.components[SphereLabelComponent.self] else {
                continue
            }
            
            let distance = sphereLabelComponent.radius * globeEntity.transform.scale.y + sphereLabelComponent.offset
            let parentPosition = globeEntity.position(relativeTo: nil)
            let position = [0, distance, 0] + parentPosition
            entity.look(at: cameraPosition, from: position, relativeTo: nil, forward: .positiveZ)
            entity.setScale([1, 1, 1], relativeTo: nil)
        }
    }

}
