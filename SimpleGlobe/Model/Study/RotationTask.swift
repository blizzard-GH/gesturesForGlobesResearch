//
//  RotationTask.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation

class RotationTask: StudyTask {
    var startTime: Date? = nil
    var endTime: Date? = nil
    var duration: TimeInterval? = nil
    var accuracyResult: Int = 0
    
    func start(){
        startTime = .now
    }
    
    func end(){
        endTime = .now
        calculateDuration()
    }
    
    private func calculateDuration() {
        guard let startTime = startTime, let endTime = endTime else {
            Log.error("Start or end time is missing.")
            return
        }
        
        duration = endTime.timeIntervalSince(startTime)
    }
    
    var taskDescription : String? {
        guard let duration else {
            return "Task not completed."
        }
        return "Task duration : \(duration) seconds."
    }
}
