//
//  TaskStorageManager.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 21/1/2025.
//
import Foundation

@MainActor
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
    
    private var userID: Int = 0
    
    private var taskCounter: Int = 1

    
    func initialiseUserID() {
//        if userID == 0 {
//            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "study_tasks.csv", directoryHint: .notDirectory)
//            userID = getLastUserID(fileURL: fileURL) + 1
//        }
        if userID == 0 {
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "study_tasks.csv", directoryHint: .notDirectory)
            // Get the last userID from the CSV and increment it
            cleanCSVFile(fileURL: fileURL)
            userID = getLastUserID(fileURL: fileURL) + 1
        }
        
    }
    
    @MainActor
    func saveTask<T: StudyTask>(_ task: T, type: TaskType) {
        let fileName = "study_tasks.csv"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentDirectory.appending(path: fileName, directoryHint: .notDirectory)
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        
        var csvString = ""
                
        if !fileExists {
            csvString += "UserID,TaskID,ActionID,rotateGlobeWhileDragging,oneHandedRotationGesture,moveGlobeWhileScaling,distance,direction,complexity,zoomDirection,Date,Type,ActionStatus,main_translation_x,main_translation_y,main_translation_z,main_rotation_x,main_rotation_y,main_rotation_z,main_rotation_w,main_scale_x,main_scale_y,main_scale_z,target_translation_x,target_translation_y,target_translation_z,target_rotation_x,target_rotation_y,target_rotation_z,target_rotation_w,target_scale_x,target_scale_y,target_scale_z,match_accuracy_result,status\n"
        }
        
        // Convert each action to a CSV row
        let rows = task.actions.elements.enumerated().map { (index, action) in
            
            let date = ISO8601DateFormatter().string(from: action.date)
            let rotateGlobeWhileDragging = ViewModel.shared.rotateGlobeWhileDragging
            let distance = PositionCondition.currentDistance
            let direction = PositionCondition.currentDirection
            let oneHandedRotationGesture = ViewModel.shared.oneHandedRotationGesture
            let complexity = RotationCondition.currentComplexity
            let moveGlobeWhileScaling = ViewModel.shared.moveGlobeWhileScaling
            let zoomDirection = ScaleCondition.currentZoomDirection
            let targetTranslation = "\(action.targetTransform.translation.x),\(action.targetTransform.translation.y),\(action.targetTransform.translation.z)"
            let targetRotationVector = action.targetTransform.rotation.vector
            let targetRotation = "\(targetRotationVector.x),\(targetRotationVector.y),\(targetRotationVector.z),\(targetRotationVector.w)"
            let targetScale = "\(action.targetTransform.scale.x),\(action.targetTransform.scale.y),\(action.targetTransform.scale.z)"
            let originalTranslation = "\(action.originalTransform.translation.x),\(action.originalTransform.translation.y),\(action.originalTransform.translation.z)"
            let originalRotationVector = action.originalTransform.rotation.vector
            let originalRotation = "\(originalRotationVector.x),\(originalRotationVector.y),\(originalRotationVector.z),\(originalRotationVector.w)"
            let originalScale = "\(action.originalTransform.scale.x),\(action.originalTransform.scale.y),\(action.originalTransform.scale.z)"
            let typeString = type.fileName
            
            let totalActions = task.actions.elements.count
            let isFirstAttempt = (index == 0 && totalActions > 0)
            let isLastAttempt = (index == totalActions - 1 && totalActions > 0)

            let taskID: String = {
                
                switch type {
                    case .position:
                    var posBehaviour: String { rotateGlobeWhileDragging ? "RG" : "NRG" }
                    var distCode: String { distance == .near ? "N" : "F" }
                    var dirCode: String {
                        switch direction {
                        case .vertical:
                            return "V"
                        case .horizontal:
                            return "H"
                        case .diagonal:
                            return "D"
                        default:
                        return "U"}
                    }
                        return "U\(userID)_P_\(posBehaviour)\(distCode)\(dirCode)_\(String(format: "%04d", taskCounter))"
                        
                    case .rotation:
                    var rotBehaviour: String { oneHandedRotationGesture ? "OH" : "TH" }
                    var compCode: String { complexity == .simple ? "S" : "C" }
                        return "U\(userID)_R_\(rotBehaviour)\(compCode)_\(String(format: "%04d", taskCounter))"
                        
                    case .scale:
                    var scaleBehaviour: String { moveGlobeWhileScaling ? "MG" : "NMG" }
                    var zoomCode: String { zoomDirection == .smallToLarge ? "StL" : "LtS" }
                        return "U\(userID)_S_\(scaleBehaviour)\(zoomCode)_\(String(format: "%04d", taskCounter))"
                    }
            }()
            
            // Determine attempt status
            let status: String = {
                switch (isFirstAttempt, isLastAttempt, task.isMatching) {
                case (_, true, true):
                    return "Matched"
                case (_, true, false):
                    return "Unmatched"
                case (true, _, _):
                    return "Attempt started"
                default:
                    return "Attempting"
                }
            }()
            
            var matchAccuracy: Float { (status == "Matched" || status == "Unmatched") ? task.accuracyResult : 0.0}

            if status == "Matched" {
                taskCounter += 1
            }
            
            return "\(userID),\(taskID),\(action.actionID.uuidString),\(rotateGlobeWhileDragging),\(oneHandedRotationGesture),\(moveGlobeWhileScaling),\(distance),\(direction),\(complexity),\(zoomDirection),\(date),\(typeString),\(action.status),\(originalTranslation),\(originalRotation),\(originalScale),\(targetTranslation),\(targetRotation),\(targetScale),\(matchAccuracy),\(status)"
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
            Log.info("Data saved to \(fileURL.path)")
            Log.info("Path: \(fileURL.path)")
        } catch {
            Log.error("Failed to save CSV: \(error.localizedDescription)")
        }
    }
    
//    private func getLastUserID(fileURL: URL) -> Int {
//        guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else {
//            return 0
//        }
//        
//        let fileContent = String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
//        fileHandle.closeFile()
//
//        let lines = fileContent?.split(separator: "\n").filter { !$0.isEmpty }
//        if let lastLine = lines?.last {
//            let components = lastLine.split(separator: ",")
//            if let lastUserIDString = components.first, let lastUserID = Int(lastUserIDString) {
//                return lastUserID  // Return the last used userID
//            }
//        }
//
//        return 0
//    }
    
    func cleanCSVFile(fileURL: URL) {
        do {
            let originalData = try Data(contentsOf: fileURL)
            var content = String(decoding: originalData, as: UTF8.self)

            let originalContent = content

            if content.hasPrefix("\u{feff}") {
                content = content.replacingOccurrences(of: "\u{feff}", with: "")
                print("Removed BOM from CSV.")
            }

            let cleanedContent = content
                .replacingOccurrences(of: "\r\n", with: "\n")
                .replacingOccurrences(of: "\r", with: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines) + "\n" // ensure only one final newline

            if cleanedContent != originalContent {
                print("Cleaned up line endings and extra whitespace.")
            } else {
                print("No BOM or line ending issues detected.")
            }

            try cleanedContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Cleaned CSV saved back to: \(fileURL.lastPathComponent)")

        } catch {
            print("Failed to clean CSV file: \(error.localizedDescription)")
        }
    }
    
    private func getLastUserID(fileURL: URL) -> Int {
        guard let fileHandle = try? FileHandle(forReadingFrom: fileURL) else {
            return 0
        }

        let fileContent = String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
        fileHandle.closeFile()

        let lines = fileContent?
            .split(separator: "\n", omittingEmptySubsequences: false)
            .reversed()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if let lastValidLine = lines?.first(where: { !$0.isEmpty && !$0.starts(with: "UserID") }) {
            let components = lastValidLine.split(separator: ",")
            if let userIDString = components.first, let userID = Int(userIDString) {
                return userID
            }
        }

        return 0
    }
}
