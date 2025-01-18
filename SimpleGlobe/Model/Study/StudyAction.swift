//
//  StudyAction.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation
import RealityKit

enum GestureStatus {
    case dragStart
    case drag
    case dragEnd
    case undefined
}

struct StudyAction: CustomStringConvertible {
    let date: Date
    let type: GestureType
    let status: GestureStatus
    let transform: Transform
    
    var description: String {
        let date = dateFormatter.string(from: date)
        let scale = String(format: "%.4f", transform.scale.x)
        let x = String(format: "%.3f", transform.translation.x)
        let y = String(format: "%.3f", transform.translation.y)
        let z = String(format: "%.3f", transform.translation.z)
        let rotation = transform.rotation
        let translation = "\(x), \(y), \(z)"
        return "\(date), \(type), \(status), scale: \(scale), xyz: \(translation), rotation: \(rotation)"
    }
    
    init(type: GestureType, status: GestureStatus, transform: Transform) {
        self.date = .now
        self.type = type
        self.status = status
        self.transform = transform
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd H:mm:ss.SSSS"
        return formatter
    }()
}
