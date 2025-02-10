//
//  StudyAction.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation
import RealityKit

struct StudyAction: CustomStringConvertible {
    let taskID: UUID
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
    
    init(taskID: UUID,
         type: GestureType,
         status: GestureStatus,
         originalTransform: Transform,
         targetTransform: Transform) {
        self.taskID = taskID
        self.date = .now
        self.type = type
        self.status = status
        self.targetTransform = targetTransform
        self.originalTransform = originalTransform
    }
    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(taskID, forKey: .taskID)
//        try container.encode(date, forKey: .date)
//        try container.encode(type, forKey: .type)
//        try container.encode(status, forKey: .status)
//        try container.encode(transform, forKey: .transform)
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case taskID
//        case date
//        case type
//        case status
//        case transform
//    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd H:mm:ss.SSSS"
        return formatter
    }()
}
