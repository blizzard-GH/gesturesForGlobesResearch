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
    
    func saveTask<T: Encodable>(_ task: T, type: TaskType) {         
         let encoder = JSONEncoder()
         encoder.outputFormatting = [.prettyPrinted]
         do {
             let directoryURL = getDocumentsDirectory().appendingPathComponent("studyTasks")
             
             // Check if directory exists, if not this will create it
             if !FileManager.default.fileExists(atPath: directoryURL.path) {
                 try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
             }
             
             let fileURL = getUniqueFileURL(directoryURL: directoryURL, baseFilename: type.fileName, fileExtension: "json")
             let data = try encoder.encode(task)
             try data.write(to: fileURL)
             print("PositionTask saved successfully.")
         } catch {
             print("Failed to save PositionTask: \(error.localizedDescription)")
         }
     }
     
     
     
    func getDocumentsDirectory() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let customDirectory = documentDirectory.appendingPathComponent("GestureForGlobesStudyData")
        
//        return customDirectory

        return URL(fileURLWithPath: "/Users/bjen0001/Desktop") // Hardcoded for testing purpose only
    }
    
    
    func getUniqueFileURL(directoryURL: URL, baseFilename: String, fileExtension: String) -> URL {
        var fileURL = directoryURL.appendingPathComponent("\(baseFilename).\(fileExtension)")
        var counter = 1

        while FileManager.default.fileExists(atPath: fileURL.path) {
            fileURL = directoryURL.appendingPathComponent("\(baseFilename)(\(counter)).\(fileExtension)")
            counter += 1
        }

        return fileURL
    }
}
