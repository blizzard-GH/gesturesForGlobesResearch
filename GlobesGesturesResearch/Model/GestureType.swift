//
//  GestureType.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 12/1/2025.
//

enum GestureType: Encodable {
    case position
    case rotation
    case scale

    enum CodingKeys: String, CodingKey {
        case position = "position"
        case rotation = "rotation"
        case scale = "scale"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .position:
            try container.encode("position")
        case .rotation:
            try container.encode("rotation")
        case .scale:
            try container.encode("scale")
        }
    }
    
    var startStatus: GestureStatus {
        switch self {
        case .position: return .dragStart
        case .rotation: return .rotateStart
        case .scale: return .magnifyStart
        }
    }
    
    var endStatus: GestureStatus {
        switch self {
        case .position: return .dragEnd
        case .rotation: return .rotateEnd
        case .scale: return .magnifyEnd
        }
    }
    
    var maxRepetition: Int {
        switch self {
        case .position : return 4
        case .rotation : return 4
        case .scale : return 4
        }
    }
}
