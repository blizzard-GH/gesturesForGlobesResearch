//
//  StudyModel.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 12/12/2024.
//

import Foundation

struct StudyTask {
    var startTime: Date? = nil
    var endTime: Date? = nil
    
    func dragEnded(time: Date) {
        print("drag ended at \(time)")
    }
}

@Observable
class StudyModel {
    var positionMatcher = PositionMatcher()
    var currentTask = StudyTask()
    var tasks: [StudyTask] = []
}
