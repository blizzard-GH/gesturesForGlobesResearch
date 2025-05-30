//
//  CSVLoaderForRotation.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 7/2/2025.
//

import Foundation

@MainActor
struct RotationCondition {
    let status: String
    let condition1: String
    let condition2: String
    
//    static var gestureFeatureCompleted: Bool = false // Used to switch between technique in experiment 1 and 2
    
    static var lastUsedRotationConditionIndex: Int = -1
    
    static var rotationConditionsCompleted: Bool = false // Used to show 'next' button once all conditions are done
    
//    static var rotationSwapTechnique: Bool = false // This var will swap technique, so that technique is implemented to Balanced Latin Square by half order

    static var rotationGestureOrder :  ModalityOrder = .oneHandedRotationFirst
    
    //Only for printing in csv
    static var currentComplexity: Complexity = .simple
    
    
    enum ModalityOrder{
        case oneHandedRotationFirst
        case twoHandedRotationFirst
        
        var list: [RotationGestureModality] {
            switch self {
            case .oneHandedRotationFirst:
                return [.oneHanded, .twoHanded]
            case .twoHandedRotationFirst:
                return [.twoHanded, .oneHanded]
            }
        }
    }
    
    enum Complexity {
        case simple
        case complex
    }
    
    enum RotationGestureModality {
        case oneHanded
        case twoHanded
    }
    
    /// Load `Landmark`s from CSV file in the app bundle.
    /// - Returns: Loaded landmarks.
    static func loadRotationConditions() throws -> [RotationCondition] {

        let fileName = "Rotation.csv"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let csvFileURL = documentDirectory.appending(path: fileName, directoryHint: .notDirectory)
        
        let data = try String(contentsOf: csvFileURL, encoding: .utf8)
        var rotationConditions: [RotationCondition] = []
        let rows = data.split(whereSeparator: \.isNewline).dropFirst().filter { !$0.isEmpty }
        //let rows = data.split(separator: "\n").dropFirst() // Skip header row
        for (index, row) in rows.enumerated() {
            let columns = row.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard columns.count == 3
            else {
                throw NSError(domain: "CSVLoader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid row format in CSV: \(row)"])
            }
            let rotationCondition = RotationCondition(status: columns[0],
                                                      condition1: columns[1],
                                                      condition2: columns[2])
            rotationConditions.append(rotationCondition)
            
            if index.isMultiple(of: 2) && columns[0] == "Active" {
                rotationGestureOrder = .twoHandedRotationFirst
            }
        }
        return rotationConditions
    }
    
    static func saveRotationConditions(rotationConditions: [RotationCondition]) throws {

        
        let fileName = "Rotation.csv"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let csvFileURL = documentDirectory.appending(path: fileName, directoryHint: .notDirectory)

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
    
    static func rotationConditionsGetter(for rotationConditions: [RotationCondition], lastUsedIndex: Int) -> (modalityOrderList: [RotationGestureModality], complexity: Complexity) {
//        var activeSubject: ScalingCondition?
//        let modality: RotationGestureModality = gestureFeatureCompleted ? .oneHanded : .twoHanded
        let modalityOrderList = rotationGestureOrder.list
        
        var complexity: Complexity = .simple
        
        guard let activeSubject = rotationConditions.first(where: { $0.status == "Active"}) else {
            Log.error("No active subject exists.")
            return ([.oneHanded, .twoHanded], .simple)
        }
        
        
        let conditionValues = [activeSubject.condition1,
                           activeSubject.condition2]
        
        if conditionValues.isEmpty {
            Log.error("No conditions available.")
            return ([.oneHanded, .twoHanded], .simple)
        }
        
        
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
        
        currentComplexity = complexity

        return (modalityOrderList, complexity)
    }
    
    static func rotationConditionsSetter(for rotationConditions: [RotationCondition], lastUsedIndex: inout Int) {
        guard let activeSubject = rotationConditions.first(where: { $0.status == "Active"}) else {
            Log.error("No active subject exists.")
            return
        }
        
        let conditionValues = [activeSubject.condition1,
                           activeSubject.condition2]
        
        if conditionValues.isEmpty {
            Log.error("No conditions available.")
            return
        }
        
        if (lastUsedIndex + 1) == conditionValues.count {
            rotationConditionsCompleted = true
            lastUsedIndex = -1
        } else {
            lastUsedIndex += 1
        }        
    }
}
