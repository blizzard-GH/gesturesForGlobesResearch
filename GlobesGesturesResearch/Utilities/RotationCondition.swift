//
//  CSVLoaderForRotation.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 7/2/2025.
//

import Foundation


struct RotationCondition {
    let status: String
    let condition1: String
    let condition2: String
    
    static var gestureFeatureCompleted: Bool = false
    
    static var lastUsedRotationConditionIndex: Int = -1
    
    static var rotationConditionsCompleted: Bool = false
    
    enum Complexity {
        case simple
        case complex
    }
    
    enum Modality {
        case oneHanded
        case twoHanded
    }
    
    /// Load `Landmark`s from CSV file in the app bundle.
    /// - Returns: Loaded landmarks.
    static func loadRotationConditions() throws -> [RotationCondition] {
//        guard let url = Bundle.main.url(forResource: "Rotation", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Rotation.csv' not found in the app bundle."])
//        }
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
        let csvFileURL = currentDirectoryURL.appendingPathComponent("Rotation.csv")
        
        let data = try String(contentsOf: csvFileURL, encoding: .utf8)
        var rotationConditions: [RotationCondition] = []
        let rows = data.split(whereSeparator: \.isNewline).dropFirst().filter { !$0.isEmpty }
        //let rows = data.split(separator: "\n").dropFirst() // Skip header row
        for row in rows {
            let columns = row.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard columns.count == 5
            else {
                throw NSError(domain: "CSVLoader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid row format in CSV: \(row)"])
            }
            let rotationCondition = RotationCondition(status: columns[0],
                                                      condition1: columns[1],
                                                      condition2: columns[2])
            rotationConditions.append(rotationCondition)
        }
        return rotationConditions
    }
    
    static func saveRotationConditions(rotationConditions: [RotationCondition]) throws {
//        guard let url = Bundle.main.url(forResource: "Rotation", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Rotation.csv' not found in the directory."])
//        }
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
        let csvFileURL = currentDirectoryURL.appendingPathComponent("Rotation.csv")

        guard let activeIndex = rotationConditions.firstIndex(where: { $0.status == "Active" }) else {
            throw NSError(domain: "CSVLoader", code: 3, userInfo: [NSLocalizedDescriptionKey: "No active condition found"])
        }

        var updatedConditions = rotationConditions

        updatedConditions[activeIndex] = RotationCondition(status: "Inactive",
                                                          condition1: rotationConditions[activeIndex].condition1,
                                                          condition2: rotationConditions[activeIndex].condition2)

        let nextIndex = (activeIndex + 1) % rotationConditions.count

        updatedConditions[nextIndex] = RotationCondition(status: "Active",
                                                        condition1: rotationConditions[nextIndex].condition1,
                                                        condition2: rotationConditions[nextIndex].condition2)

        let csvHeader = "status,condition1,condition2,condition3,condition4\n"
        let csvRows = updatedConditions.map { "\($0.status),\($0.condition1),\($0.condition2)" }
        let csvString = csvHeader + csvRows.joined(separator: "\n")

        try csvString.write(to: csvFileURL, atomically: true, encoding: .utf8)
    }
    
    static func rotationConditionsGetter(for rotationConditions: [RotationCondition], lastUsedIndex: Int) -> (modalitiy: Modality, complexity: Complexity) {
//        var activeSubject: ScalingCondition?
        var modality: Modality = gestureFeatureCompleted ? .oneHanded : .twoHanded
        var complexity: Complexity = .simple
        
        
        guard let activeSubject = rotationConditions.first(where: { $0.status == "Active"}) else {
            print("No active subject exists.")
            return (.oneHanded, .simple)
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
            return (.oneHanded, .simple)
        }
        
//        for condition in conditionValues {
//        conditionValues.forEach { condition in
        
//        rotationConditionsSetter(for: rotationConditions, lastUsedIndex: &lastUsedIndex)
        let safeIndex = min(max(lastUsedIndex, 0), conditionValues.count - 1)
        
        let selectedCondition = conditionValues[safeIndex]

        switch selectedCondition {
        case "A":
            complexity = .simple
        case "B" :
            complexity = .complex
        default:
            break
        }
//        }
        return (modality, complexity)
    }
    
    static func rotationConditionsSetter(for rotationConditions: [RotationCondition], lastUsedIndex: inout Int) {
        guard let activeSubject = rotationConditions.first(where: { $0.status == "Active"}) else {
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
            rotationConditionsCompleted = true
            lastUsedIndex = -1
        } else {
            lastUsedIndex += 1
        }        
    }
}
