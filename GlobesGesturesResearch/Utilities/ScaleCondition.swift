//
//  CSVLoader.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 7/2/2025.
//

import Foundation


struct ScaleCondition {
    let status: String
    let condition1: String
    let condition2: String
    
    static var gestureFeatureCompleted: Bool = false

    static var lastUsedScaleConditionIndex: Int = -1
    
    static var scaleConditionsCompleted: Bool = false
    
    enum MovingGlobe {
        case notMoving
        case moving
    }
    
    enum ZoomDirection {
        case smallToLarge
        case largeToSmall
    }
    
    /// Load `Landmark`s from CSV file in the app bundle.
    /// - Returns: Loaded landmarks.
    static func loadScaleConditions() throws -> [ScaleCondition] {
//        guard let url = Bundle.main.url(forResource: "Scaling", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Scaling.csv' not found in the directory."])
//        }
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
        let csvFileURL = currentDirectoryURL.appendingPathComponent("Scaling.csv")
        
        let data = try String(contentsOf: csvFileURL, encoding: .utf8)
        var scalingConditions: [ScaleCondition] = []
        let rows = data.split(whereSeparator: \.isNewline).dropFirst().filter { !$0.isEmpty }
        //let rows = data.split(separator: "\n").dropFirst() // Skip header row
        for row in rows {
            let columns = row.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard columns.count == 5
            else {
                throw NSError(domain: "CSVLoader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid row format in CSV: \(row)"])
            }
            let scalingCondition = ScaleCondition(status: columns[0],
                                                    condition1: columns[1],
                                                    condition2: columns[2])
            scalingConditions.append(scalingCondition)
        }
        return scalingConditions
    }
    
    static func saveScaleConditions(scaleConditions: [ScaleCondition]) throws {
//        guard let url = Bundle.main.url(forResource: "Scaling", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Scaling.csv' not found in the app bundle."])
//        }
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
        let csvFileURL = currentDirectoryURL.appendingPathComponent("Scaling.csv")

        guard let activeIndex = scaleConditions.firstIndex(where: { $0.status == "Active" }) else {
            throw NSError(domain: "CSVLoader", code: 3, userInfo: [NSLocalizedDescriptionKey: "No active condition found"])
        }

        var updatedConditions = scaleConditions

        updatedConditions[activeIndex] = ScaleCondition(status: "Inactive",
                                                          condition1: scaleConditions[activeIndex].condition1,
                                                          condition2: scaleConditions[activeIndex].condition2)

        let nextIndex = (activeIndex + 1) % scaleConditions.count

        updatedConditions[nextIndex] = ScaleCondition(status: "Active",
                                                        condition1: scaleConditions[nextIndex].condition1,
                                                        condition2: scaleConditions[nextIndex].condition2)

        let csvHeader = "status,condition1,condition2,condition3,condition4\n"
        let csvRows = updatedConditions.map { "\($0.status),\($0.condition1),\($0.condition2)" }
        let csvString = csvHeader + csvRows.joined(separator: "\n")

        try csvString.write(to: csvFileURL, atomically: true, encoding: .utf8)
    }
    
    static func scaleConditionsGetter(for scaleConditions: [ScaleCondition], lastUsedIndex: Int) -> (movingGlobe: MovingGlobe, zoomDirection: ZoomDirection) {
//        var activeSubject: ScalingCondition?
        var movingGlobe: MovingGlobe = gestureFeatureCompleted ? .moving : .notMoving
        var zoomDirection: ZoomDirection = .smallToLarge
        
        
        guard let activeSubject = scaleConditions.first(where: { $0.status == "Active"}) else {
            print("No active subject exists.")
            return (.notMoving, .smallToLarge)
        }
        
//        for subject in scalingConditions {
//            if subject.status == "Active" {
//                activeSubject = subject
//            }
//        }
//
//        guard let activeSubject = activeSubject else {
//            print("No active subject exists.")
//            return
//        }
        
        let conditionValues = [activeSubject.condition1,
                           activeSubject.condition2]
        
        if conditionValues.isEmpty {
            print("No conditions available.")
            return (.notMoving, .smallToLarge)
        }
        
//        for condition in conditionValues {
//        conditionValues.forEach { condition in
        
        let safeIndex = min(max(lastUsedIndex, 0), conditionValues.count - 1)

        
        let selectedCondition = conditionValues[safeIndex]
        switch selectedCondition {
        case "A":
            zoomDirection = .smallToLarge
        case "B" :
            zoomDirection = .largeToSmall
        default:
            break
        }
//    }
        return (movingGlobe, zoomDirection)
    }
    
    static func scaleConditionsSetter(for scaleConditions: [ScaleCondition], lastUsedIndex: inout Int) {
        guard let activeSubject = scaleConditions.first(where: { $0.status == "Active"}) else {
            print("No active subject exists.")
            return
        }
        
        let conditionValues = [activeSubject.condition1,
                           activeSubject.condition2]
        
        if conditionValues.isEmpty {
            print("No conditions available.")
            return
        }
        
        if (lastUsedIndex + 1) == conditionValues.count {
            gestureFeatureCompleted.toggle()
            scaleConditionsCompleted = true
            lastUsedIndex = -1
        } else {
            lastUsedIndex += 1
        }
    }
}
