//
//  StudyModel.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 12/12/2024.
//

import Foundation
import RealityKit

@MainActor
@Observable
class StudyModel {
    
    /// Completed position tasks
    private var positionTasks: [PositionTask] = []
    
    /// Completed rotation tasks
    private var rotationTasks: [RotationTask] = []
    
    /// Completed scale tasks
    private var scaleTasks: [ScaleTask] = []
            
//    Current task
    var currentTask: StudyTask?
    var currentTaskPage: Page = .welcome
    
    /// Create the next task
    func setupNextTask(gestureType: GestureType, originalTransform: Transform, targetTransform: Transform) {
        switch gestureType {
        case .position:
            currentTask = PositionTask(originalPosition: originalTransform.translation,
                                       targetPosition: targetTransform.translation)
        case .rotation:
            currentTask = RotationTask(originalRotation: originalTransform.rotation,
                                       targetRotation: targetTransform.rotation)
        case .scale:
            currentTask = ScaleTask(originalScale: originalTransform.scale.x,
                                    targetScale: targetTransform.scale.x)
        }
    }
    
    func storeTask() {
        guard let task = currentTask else { return }
        Log.task(task)
        print(task.isMatching ? "Position matched." : "Position is not matched.")
        task.saveToFile()
        
        switch task {
        case let task as PositionTask:
            positionTasks.append(task)
        case let task as RotationTask:
            rotationTasks.append(task)
        case let task as ScaleTask:
            scaleTasks.append(task)
        default:
            fatalError("Unknown task type")
        }
        currentTask = nil
    }
    
    func log() {
        Log.info("\(positionTasks.count) position tasks completed")
        for task in positionTasks {
            Log.task(task)
        }
        
        Log.info("\(rotationTasks.count) rotation tasks completed")
        for task in rotationTasks {
            Log.task(task)
        }
        
        Log.info("\(scaleTasks.count) scale tasks completed")
        for task in scaleTasks {
            Log.task(task)
        }
    }
}
