//
//  GestureStatus.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 21/1/2025.
//

import Foundation
import RealityKit

enum GestureStatus: Encodable {
    case dragStart
    case drag
    case dragEnd
    case undefined

    enum CodingKeys: String, CodingKey {
        case dragStart = "dragStart"
        case drag = "drag"
        case dragEnd = "dragEnd"
        case undefined = "undefined"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .dragStart:
            try container.encode("dragStart")
        case .drag:
            try container.encode("drag")
        case .dragEnd:
            try container.encode("dragEnd")
        case .undefined:
            try container.encode("undefined")
        }
    }
}
