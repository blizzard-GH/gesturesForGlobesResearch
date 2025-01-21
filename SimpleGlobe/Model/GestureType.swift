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
}
