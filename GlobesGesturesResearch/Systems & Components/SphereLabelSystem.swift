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

struct SphereLabelSystem: System {
    static let query = EntityQuery(where: .has(SphereLabelComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let globeEntity = entity.parent,
                  let sphereLabelComponent = entity.components[SphereLabelComponent.self] else {
                continue
            }
            
            let distance = sphereLabelComponent.radius + sphereLabelComponent.offset / globeEntity.transform.scale.y
            let top = globeEntity.transform.rotation.inverse.act([0, distance, 0])
            entity.setPosition(top, relativeTo: globeEntity)
            entity.setScale([1, 1, 1], relativeTo: nil)
        }
    }

}


