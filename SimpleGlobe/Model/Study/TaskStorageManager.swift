//
//  TaskStorageManager.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 21/1/2025.
//
import Foundation

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
    
    @MainActor
    func saveTask<T: StudyTask>(_ task: T, type: TaskType) {
        let fileName = "study_tasks.csv"
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        
        var csvString = ""
        
        
        if !fileExists {
            csvString += "date,type,status,translation_x,translation_y,translation_z,rotation_x,rotation_y,rotation_z,rotation_w,scale_x,scale_y,scale_z,accuracy_result\n"
        }
        
        // Convert each action to a CSV row
        let rows = task.actions.elements.map { action in
            let date = ISO8601DateFormatter().string(from: action.date)
            let translation = "\(action.transform.translation.x),\(action.transform.translation.y),\(action.transform.translation.z)"
            let rotationVector = action.transform.rotation.vector
            let rotation = "\(rotationVector.x),\(rotationVector.y),\(rotationVector.z),\(rotationVector.w)"
            let scale = "\(action.transform.scale.x),\(action.transform.scale.y),\(action.transform.scale.z)"
            let typeString = type.fileName
            
            return "\(date),\(typeString),\(action.status),\(translation),\(rotation),\(scale),\(task.accuracyResult)"
        }
        
        csvString += rows.joined(separator: "\n") + "\n"
        
        do {
            if fileExists {
                // Append to existing file
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                if let data = csvString.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } else {
                // Create new file and write content
                try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            }
            print("Data saved to \(fileURL.path)")
        } catch {
            print("Failed to save CSV: \(error.localizedDescription)")
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
     
    func getDocumentsDirectory() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let customDirectory = documentDirectory.appendingPathComponent("GestureForGlobesStudyData")
        
//        return customDirectory

//        Harcoded for testing purpose only:
//        return URL(fileURLWithPath: "/Users/bjen0001/Desktop")  //Bernie's
        return URL(fileURLWithPath: "/Users/faisalabdillah/Desktop") //Faisal's
    }
    
    
//    func getUniqueFileURL(directoryURL: URL, fileName: String, fileExtension: String) -> URL {
//        var fileURL = directoryURL.appendingPathComponent("\(fileName).\(fileExtension)")
//        var counter = 1
//
//        while FileManager.default.fileExists(atPath: fileURL.path) {
//            fileURL = directoryURL.appendingPathComponent("\(fileName)(\(counter)).\(fileExtension)")
//            counter += 1
//        }
//
//        return fileURL
//    }
}
