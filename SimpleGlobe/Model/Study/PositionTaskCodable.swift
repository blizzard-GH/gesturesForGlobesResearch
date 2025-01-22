//
//  PositionTaskCodable.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 21/1/2025.
//


struct PositionTaskCodable: Encodable {
    var actions: [StudyAction]
    var accuracyResult: Float
    
    init(actions: [StudyAction], accuracyResult: Float) {
        self.actions = actions
        self.accuracyResult = accuracyResult
    }
}


