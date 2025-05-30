//
//  StudyAction.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation
import RealityKit

struct StudyAction: CustomStringConvertible {
    let actionID: UUID
    let date: Date
    let type: GestureType
    let status: GestureStatus
    let originalTransform: Transform
    let targetTransform: Transform
    
    var description: String {
        let date = dateFormatter.string(from: date)
        let targetScale = String(format: "%.4f", targetTransform.scale.x)
        let targetX = String(format: "%.3f", targetTransform.translation.x)
        let targetY = String(format: "%.3f", targetTransform.translation.y)
        let targetZ = String(format: "%.3f", targetTransform.translation.z)
        let targetRotation = targetTransform.rotation
        let targetTranslation = "\(targetX), \(targetY), \(targetZ)"
        return "\(date), \(type), \(status), scale: \(targetScale), xyz: \(targetTranslation), rotation: \(targetRotation)"
    }
    
    init(actionID: UUID,
         type: GestureType,
         status: GestureStatus,
         originalTransform: Transform,
         targetTransform: Transform) {
        self.actionID = actionID
        self.date = .now
        self.type = type
        self.status = status
        self.targetTransform = targetTransform
        self.originalTransform = originalTransform
    }
    
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd H:mm:ss.SSSS"
        return formatter
    }()
}
