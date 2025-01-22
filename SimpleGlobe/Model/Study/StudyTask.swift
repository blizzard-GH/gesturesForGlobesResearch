//
//  StudyTask.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation
import RealityKit

@MainActor
protocol StudyTask: CustomStringConvertible {
    var actions: [StudyAction] { get set }
    var matcher: Matcher { get }
    
    /// Accuracy result
    var accuracyResult: Int {get}
    
    func saveToFile()
}

extension StudyTask {
    
    var startTime: Date? { actions.first?.date }
    var endTime: Date? { actions.last?.date }
    
    /// Duration of task between start and end times.
    var duration: TimeInterval? {
        guard let startTime = startTime, let endTime = endTime else {
            Log.error("Start time or end time is missing.")
            return nil
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    var taskDescription: String {
        let actionDescriptions = actions.map { $0.description }.joined(separator: ",\n")
        let durationInfo = (duration == nil) ? "?" : "\(duration!) seconds"
        return "Task duration: \(durationInfo)\nActions:\n\(actionDescriptions)"
    }
    
    mutating func start(type: GestureType, transform: Transform) {
        Log.info("Start gesture \(type)")
        addAction(StudyAction(type: type, status: .dragStart, transform: transform))
    }
    
    mutating func end(type: GestureType, transform: Transform) {
        Log.info("End gesture \(type)")
        addAction(StudyAction(type: type, status: .dragEnd, transform: transform))
    }
    
    mutating func addAction(_ action: StudyAction) {
        actions.append(action)
    }
    
    var isMatching: Bool {
        guard let lastTransform = actions.last?.transform else { return false }
        return matcher.isMatching(lastTransform)
    }
}

extension StudyTask {
    var description: String {
        taskDescription
    }
}

