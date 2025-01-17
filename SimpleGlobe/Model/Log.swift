//
//  Log.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation
import os

actor Log {
    static func task(_ task: StudyTask?) {
        if let task, let taskDescription = task.taskDescription {
            Task {
                await shared.append(task)
            }
            shared.logger.info("\(taskDescription)")
        } else {
            Log.error("Logging invalid task")
        }
    }
    
    static func error(_ message: String) {
        shared.logger.error("\(message)")
    }
    
    private static let shared = Log()
    
    private let logger: Logger = {
        let bundleID = Bundle.main.bundleIdentifier!
        return Logger(subsystem: "\(bundleID).studylog", category: "Log")
    }()
    
    private init() {} // hide initializer
    
    private func append(_ task: StudyTask) {
        tasks.append(task)
    }
    
    private var tasks: [StudyTask] = []
}
