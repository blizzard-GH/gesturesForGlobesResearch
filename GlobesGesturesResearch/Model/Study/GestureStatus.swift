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
    case magnifyStart
    case magnify
    case magnifyEnd
    case rotateStart
    case rotate
    case rotateEnd
    case undefined

    enum CodingKeys: String, CodingKey {
        case dragStart = "dragStart"
        case drag = "drag"
        case dragEnd = "dragEnd"
        case magnifyStart = "magnifyStart"
        case magnify = "magnify"
        case magnifyEnd = "magnifyEnd"
        case rotateStart = "rotateStart"
        case rotate = "rotate"
        case rotateEnd = "rotateEnd"
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
        case .magnifyStart:
            try container.encode("magnifyStart")
        case .magnify:
            try container.encode("magnify")
        case .magnifyEnd:
            try container.encode("magnifyEnd")
        case .rotateStart:
            try container.encode("rotateStart")
        case .rotate:
            try container.encode("rotate")
        case .rotateEnd:
            try container.encode("rotateEnd")
        case .undefined:
            try container.encode("undefined")
        }
    }
}
