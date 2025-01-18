//
//  StudyTask.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation

protocol StudyTask {
    var taskDescription: String? {get}
    func start()
    func end()
    
    /// Time needed
    var duration: TimeInterval? {get}

    /// Accuracy result
    var accuracyResult: Int {get}
}

