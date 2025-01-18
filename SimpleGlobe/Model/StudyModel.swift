//
//  StudyModel.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 12/12/2024.
//

import Foundation

@Observable
class StudyModel {

//    Matchers
    private let positionMatcher = PositionMatcher()
    private let rotationMatcher = RotationMatcher()
    private let scaleMatcher = ScaleMatcher()
    
    private var positioningTasks: [PositioningTask] = []
    private var rotationTasks: [RotationTask] = []
    private var scaleTasks: [ScaleTask] = []
            
//    Current task
    private var currentTask: StudyTask?
    var currentTaskPage: Page = .task1a
    var currentTaskGesture: GestureType = .positioning
    
    /// Task switching
    func startNextTask(gestureType: GestureType) {
        currentTask = createTask(for: gestureType)
        currentTask?.start()
    }
    
    func createTask(for gestureType: GestureType) -> StudyTask {
        switch gestureType {
        case .positioning: return PositioningTask()
        case .rotation: return RotationTask()
        case .scale: return ScaleTask()
        }
    }
    
    func endTask() {
        guard let task = currentTask else {return}
        task.end()
        
        switch task {
        case let task as PositioningTask:
            end(task)
        case let task as RotationTask:
            end(task)
        case let task as ScaleTask:
            end(task)
        default:
            fatalError("Unknown task type")
        }
        currentTask = nil
        
        func end(_ task: PositioningTask) {
            positioningTasks.append(task)
            
            Log.task(task)
            if positionMatcher.isPositionMatched {
                print("Position matched.")
            } else {
                print("Position is not matched")
            }
            
            if positioningTasks.count == 3 {
                // This is the data we can study
#warning("Better to pass the task to Log.task() and log all information there")
                print("\(printAverageTimeTaskDurations(timeTasks: positioningTasks))")
                positioningTasks.removeAll()
            }
        }
        
        func end(_ task: RotationTask) {
            rotationTasks.append(task)
            
            Log.task(task)
            if rotationMatcher.isRotationMatched {
                print("Rotation matched.")
            } else {
                print("Rotation is not matched.")
            }
            
            if rotationTasks.count == 3 {
                // This is the data we can study
#warning("Better to pass the task to Log.task() and log all information there")
                print("\(printAverageTimeTaskDurations(timeTasks: rotationTasks))")
                rotationTasks.removeAll()
            }
        }
        
        func end(_ task: ScaleTask) {
            scaleTasks.append(task)
            
            Log.task(task)
            if scaleMatcher.isScaleMatched {
                print("Scale matched.")
            } else {
                print("Scale is not matched.")
            }
            
            if scaleTasks.count == 3 {
                // This is the data we can study
#warning("Better to pass the task to Log.task() and log all information there")
                print("\(printAverageTimeTaskDurations(timeTasks: scaleTasks))")
                scaleTasks.removeAll()
            }
        }
    }
    
    func calculateAverageTimeTask(for tasks: [StudyTask]) -> Double {
        let durations = tasks.compactMap {$0.timeResult}
        guard !durations.isEmpty else { return 0.0}
        let totalDurations = durations.reduce(0, +)
        return totalDurations/Double(durations.count)
    }
    
    func printAverageTimeTaskDurations(timeTasks: [StudyTask]) -> String {
        let averageDurations = calculateAverageTimeTask(for: timeTasks)
        return "Average time needed to accomplish time tasks : \(averageDurations) seconds."
    }
    
    @MainActor
    func getMatcher(taskNumber: String, model: ViewModel) -> Bool {
        switch taskNumber{
        case "1a":
            return positionMatcher.checkPosition(model: model)
        case "1b":
            return positionMatcher.checkPosition(model: model)
        case "2a":
            return rotationMatcher.checkRotation(model: model)
        case "2b":
            return rotationMatcher.checkRotation(model: model)
        case "3a":
            return scaleMatcher.checkScale(model: model)
        case "3b":
            return scaleMatcher.checkScale(model: model)
        default:
            return false
        }
    }
}

// Required protocols
protocol StudyTask {
    var taskDescription: String? {get}
    func start()
    func end()
    
    /// Time needed
    var timeResult: TimeInterval? {get}

    /// Accuracy result
    var accuracyResult: Int {get}
}

// TimeTasks
class PositioningTask: StudyTask {
    
    var startTime: Date? = nil
    var endTime: Date? = nil
    var timeResult: TimeInterval? = nil
    var accuracyResult: Int = 0
    
    func start() {
        startTime = .now
    }

    func end() {
        endTime = .now
        calculateDuration()
    }

    private func calculateDuration() {
        guard let startTime = startTime, let endTime = endTime else {
            Log.error("Start or end time is missing.")
            return
        }
        let duration = endTime.timeIntervalSince(startTime)
        timeResult = duration
    }
    
    var taskDescription : String? {
        guard let duration = timeResult
        else {
            return "Task not completed"
        }
        return "Task duration : \(duration) seconds."
    }
}

class RotationTask: StudyTask {
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
    
    private func calculateDuration() {
        guard let startTime = startTime, let endTime = endTime else {
            Log.error("Start or end time is missing.")
            return
        }
        
        let duration = endTime.timeIntervalSince(startTime)
        timeResult = duration
    }
    
    var taskDescription : String? {
        guard let duration = timeResult
        else{
            return "Task not completed."
        }
        return "Task duration : \(duration) seconds."
    }
}

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
