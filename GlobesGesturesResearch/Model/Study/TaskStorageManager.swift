//
//  TaskStorageManager.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 21/1/2025.
//
import Foundation
import os

class TaskStorageManager {
    
    enum TaskType {
        case position
        case rotation
        case scale
        
        var fileName: String {
            switch self {
            case .position: return "positionTask"
            case .rotation: return "rotationTask"
            case .scale: return "scaleTask"
            }
        }
    }
    
    static let shared = TaskStorageManager()
    
    private init() {}
    
    static var storageFileRead: Bool {
        let fileName = "study_tasks.csv"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appending(path: fileName, directoryHint: .notDirectory)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    static var directoryPath: String {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? "Nothing"
    }
    
    @MainActor
    func saveTask<T: StudyTask>(_ task: T, type: TaskType) {
        let fileName = "study_tasks.csv"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appending(path: fileName, directoryHint: .notDirectory)
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        
        var csvString = ""
        
        if !fileExists {
            csvString += "TaskID, date,type,status,original_translation_x,original_translation_y,original_translation_z,original_rotation_x,original_rotation_y,original_rotation_z,original_rotation_w,original_scale_x,original_scale_y,original_scale_z,target_translation_x,target_translation_y,target_translation_z,target_rotation_x,target_rotation_y,target_rotation_z,target_rotation_w,target_scale_x,target_scale_y,target_scale_z,accuracy_result\n"
        }
        
        // Convert each action to a CSV row
        let rows = task.actions.elements.map { action in
            let date = ISO8601DateFormatter().string(from: action.date)
            let targetTranslation = "\(action.targetTransform.translation.x),\(action.targetTransform.translation.y),\(action.targetTransform.translation.z)"
            let targetRotationVector = action.targetTransform.rotation.vector
            let targetRotation = "\(targetRotationVector.x),\(targetRotationVector.y),\(targetRotationVector.z),\(targetRotationVector.w)"
            let targetScale = "\(action.targetTransform.scale.x),\(action.targetTransform.scale.y),\(action.targetTransform.scale.z)"
            let originalTranslation = "\(action.originalTransform.translation.x),\(action.originalTransform.translation.y),\(action.originalTransform.translation.z)"
            let originalRotationVector = action.originalTransform.rotation.vector
            let originalRotation = "\(originalRotationVector.x),\(originalRotationVector.y),\(originalRotationVector.z),\(originalRotationVector.w)"
            let originalScale = "\(action.originalTransform.scale.x),\(action.originalTransform.scale.y),\(action.originalTransform.scale.z)"
            let typeString = type.fileName
            
            return "\(action.taskID.uuidString),\(date),\(typeString),\(action.status),\(originalTranslation),\(originalRotation),\(originalScale),\(targetTranslation),\(targetRotation),\(targetScale),\(task.accuracyResult)"
        }
        
        csvString += rows.joined(separator: "\n") + "\n"
        
        do {
            if fileExists {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                if let data = csvString.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            Logger().info("Data saved to \(fileURL.path)")
        } catch {
            Logger().error("Failed to save CSV: \(error.localizedDescription)")
        }
    }
    
//    func convertToCSVRow<T: Encodable>(_ task: T) throws -> String {
//        let data = try JSONEncoder().encode(task)
//        let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
//        
//        let row = dictionary.values.map { "\($0)" }.joined(separator: ",") + "\n"
//        return row
//    }
//     
//    func extractCSVHeaders<T: Encodable>(from task: T) -> String {
//        let data = try? JSONEncoder().encode(task)
//        let dictionary = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: Any] ?? [:]
//        
//        return dictionary.keys.joined(separator: ",") + "\n"
//    }
}
