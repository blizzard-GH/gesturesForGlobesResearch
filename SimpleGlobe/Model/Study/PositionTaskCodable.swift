//
//  PositionTaskCodable.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 21/1/2025.
//


struct PositionTaskCodable: Encodable {
    var actions: [StudyAction]
    var accuracyResult: Int
    
    init(actions: [StudyAction], accuracyResult: Int) {
        self.actions = actions
        self.accuracyResult = accuracyResult
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(actions, forKey: .actions)
        try container.encode(accuracyResult, forKey: .accuracyResult)
    }
    
    enum CodingKeys: String, CodingKey {
        case actions
        case accuracyResult
    }
}


