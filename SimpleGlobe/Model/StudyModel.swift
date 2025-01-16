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
    var positionMatcher = PositionMatcher()
    var rotationMatcher = RotationMatcher()
    var scaleMatcher = ScaleMatcher()
    
//    Time tasks
    var positioningTimeTasks : [PositioningTimeTask] = []
    var rotationTimeTasks : [RotationTimeTask] = []
    var scaleTimeTasks : [ScaleTimeTask] = []
    
//    Accuracy tasks
    var positioningAccuracyTasks: PositioningAccuracyTask?
    var rotationAccuracyTasks: RotationAccuracyTask?
    var scaleAccuracyTasks: ScaleAccuracyTask?
    
//    Time Task Counters
    var positioningTimeTaskCount = 0
    var rotationTimeTaskCount = 0
    var scaleTimeTaskCount = 0
    
//    Accuracy Task Counters
    var positioningAccuracyTaskCount = 0
    var rotationAccuracyTaskCount = 0
    var scaleAccuracyTaskCount = 0
    
//    Current task
    var currentTask: GestureStudyTasks?
    var currentTaskPage: Page = .task1a
    var currentTaskGesture: GestureType = .positioning
    var currentTaskMode: TaskMode = .time
    
    
//    Task mode toggling
    func toggleTaskMode() {
        currentTaskMode = (currentTaskMode == .time) ? .accuracy: .time
    }
    
//    Unified task mode switching
    func startNextTask(taskMode: TaskMode, gestureType: GestureType) {
        switch taskMode {
        case .time:
            currentTask = createTimeTask(for: gestureType)
        case .accuracy:
            currentTask = createAccuracyTask(for: gestureType)
        }
        currentTask?.start()
    }
    
//     Time task
    func createTimeTask(for gestureType: GestureType) -> TimeTasks {
        switch gestureType {
        case .positioning: return PositioningTimeTask()
        case .rotation: return RotationTimeTask()
        case .scale: return ScaleTimeTask()
        }
    }
    
    func endTimeTask(taskType: GestureType){
        guard let task = currentTask else {return}
        task.end()
        
        switch taskType {
        case .positioning:
        guard let task = currentTask as? PositioningTimeTask else {return}
            positioningTimeTasks.append(task)
            positioningTimeTaskCount += 1
            // This is the data we can study
            print(task.taskDescription ?? "0.0")
            
            
            if positioningTimeTaskCount == 3 {
                // This is the data we can study
                print("\(printAverageTimeTaskDurations(timeTasks: positioningTimeTasks))")
                positioningTimeTaskCount = 0
                positioningTimeTasks.removeAll()
            }
        
        case .rotation:
            guard let task = currentTask as? RotationTimeTask else {return}
            rotationTimeTasks.append(task)
            rotationTimeTaskCount += 1
            // This is the data we can study
            print(task.taskDescription ?? "0.0")
            
            if rotationTimeTaskCount == 3 {
                // This is the data we can study
                print("\(printAverageTimeTaskDurations(timeTasks: rotationTimeTasks))")
                rotationTimeTaskCount = 0
                rotationTimeTasks.removeAll()
            }
        case .scale:
            guard let task = currentTask as? ScaleTimeTask else {return}
            scaleTimeTasks.append(task)
            scaleTimeTaskCount += 1
            // This is the data we can study
            print(task.taskDescription ?? "0.0")
            
            if scaleTimeTaskCount == 3 {
                // This is the data we can study
                print("\(printAverageTimeTaskDurations(timeTasks: scaleTimeTasks))")
                scaleTimeTaskCount = 0
                scaleTimeTasks.removeAll()
            }
        }
        currentTask = nil
    }
    
    
    func calculateAverageTimeTask<T: TimeTasks>(for tasks: [T]) -> Double {
        let durations = tasks.compactMap {$0.timeResult}
        guard !durations.isEmpty else { return 0.0}
        let totalDurations = durations.reduce(0, +)
        return totalDurations/Double(durations.count)
    }
    
    func printAverageTimeTaskDurations<T: TimeTasks>(timeTasks: [T]) -> String {
        let averageDurations = calculateAverageTimeTask(for: timeTasks)
        return "Average time needed to accomplish time tasks : \(averageDurations) seconds."
    }
    
//    Accuracy task
    func createAccuracyTask(for gestureType: GestureType) -> AccuracyTasks {
        switch gestureType {
        case .positioning: return PositioningAccuracyTask()
        case .rotation: return RotationAccuracyTask()
        case .scale: return ScaleAccuracyTask()
        }
    }
    
    func endAccuracyTask(taskType: GestureType) {
        guard let task = currentTask else {return}
        task.end()
        
        switch taskType {
        case .positioning:
            guard let task = currentTask as? PositioningAccuracyTask else {return}
            positioningAccuracyTaskCount += 1
            print(task.taskDescription ?? "None")
            if positionMatcher.isPositionMatched {
                print("Position matched.")
            } else {
                print("Position is not matched")
            }
        case .rotation:
            guard let task = currentTask as? RotationAccuracyTask else {return}
            rotationAccuracyTaskCount += 1
            print(task.taskDescription ?? "None")
            if rotationMatcher.isRotationMatched {
                print("Rotation matched.")
            } else {
                print("Rotation is not matched.")
            }
        case .scale:
            guard let task = currentTask as? ScaleAccuracyTask else {return}
            scaleAccuracyTaskCount += 1
            print(task.taskDescription ?? "None")
            if scaleMatcher.isScaleMatched {
                print("Scale matched.")
            } else {
                print("Scale is not matched.")
            }
        }
        currentTask = nil
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
protocol GestureStudyTasks {
    var taskDescription: String? {get}
    func start()
    func end()
}

protocol TimeTasks: GestureStudyTasks {
//    Basically timeResult is time needed for users to match the target
    var timeResult: TimeInterval? {get}
}

protocol AccuracyTasks: GestureStudyTasks {
//    Basically accuracyResult is the trials users did to match the target
    var accuracyResult: Int {get}
}

// TimeTasks
class PositioningTimeTask: TimeTasks {
    
    var startTime: Date? = nil
    var endTime: Date? = nil
    var timeResult: TimeInterval? = nil
        
    func start() {
        startTime = .now
    }

    func end() {
        endTime = .now
        calculateDuration()
    }

    private func calculateDuration() {
        guard let startTime = startTime, let endTime = endTime else {
            print("Start or end time is missing.")
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

class RotationTimeTask: TimeTasks{
    var startTime: Date? = nil
    var endTime: Date? = nil
    var timeResult: TimeInterval? = nil
        
    func start(){
        startTime = .now
    }
    
    func end(){
        endTime = .now
        calculateDuration()
    }
    
    private func calculateDuration(){
        guard let startTime = startTime, let endTime = endTime else {
            print("Start or end time is missing.")
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

class ScaleTimeTask: TimeTasks{
    var startTime: Date? = nil
    var endTime: Date? = nil
    var timeResult: TimeInterval? = nil
        
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

class PositioningAccuracyTask: AccuracyTasks {
    var accuracyResult: Int = 0
    var taskDescription: String? {
        return "Task trial(s) until succeded: \(accuracyResult) time(s)."
    }
    
    func start() {
        
    }
    
    func end() {
        accuracyResult += 1
    }
}

class RotationAccuracyTask: AccuracyTasks{
    var accuracyResult: Int = 0
    var taskDescription: String? {
        return "Task trial(s) until succeded: \(accuracyResult) time(s)."
    }
    
    func start(){
        
    }
    
    func end(){
        accuracyResult += 1
    }
}

class ScaleAccuracyTask: AccuracyTasks {
    var accuracyResult: Int = 0
    var taskDescription: String? {
        return "Task trial(s) until succeded: \(accuracyResult) time(s)."
    }
    
    func start() {
        
    }
    
    func end() {
        accuracyResult += 1
    }
}
