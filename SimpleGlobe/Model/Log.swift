//
//  Log.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation
import os

actor Log {
    
    /// Log task information
    /// - Parameter task: The task
    static func task(_ task: StudyTask?) {
        if let task, let taskDescription = task.taskDescription {
            shared.logger.info("\(taskDescription)")
        } else {
            Log.error("Logging invalid task")
        }
    }
    
    /// Log an error
    /// - Parameter message: The error message
    static func error(_ message: String) {
        shared.logger.error("\(message)")
    }
    
    private static let shared = Log()
    
    private let logger: Logger = {
        let bundleID = Bundle.main.bundleIdentifier!
        return Logger(subsystem: "\(bundleID).studylog", category: "Log")
    }()
    
    private init() {} // hide initializer
}
