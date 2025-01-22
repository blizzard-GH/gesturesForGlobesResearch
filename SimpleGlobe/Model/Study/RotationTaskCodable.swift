//
//  RotationTaskCodable.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 21/1/2025.
//

struct RotationTaskCodable: Encodable {
    var actions: [StudyAction]
    var accuracyResult: Int
    
    init(actions: [StudyAction], accuracyResult: Int) {
        self.actions = actions
        self.accuracyResult = accuracyResult
    }
}
