//
//  ScaleTask.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation

class ScaleTask: StudyTask {
    var startTime: Date? = nil
    var endTime: Date? = nil
    var timeResult: TimeInterval? = nil
    var accuracyResult: Int = 0
    
    func start(){
        startTime = .now
    }
    
    func end(){
        endTime = .now
        calculateDuration()
    }
    
    private func calculateDuration(){
        guard let startTime = startTime, let endTime = endTime else {
            print("Start time of end time is missing.")
            return
        }
        
        let duration = endTime.timeIntervalSince(startTime)
        timeResult = duration
    }
    
    var taskDescription : String? {
        guard let duration = timeResult else {
            return "Task not completed."
        }
        return "Task duration : \(duration) seconds."
    }
}
