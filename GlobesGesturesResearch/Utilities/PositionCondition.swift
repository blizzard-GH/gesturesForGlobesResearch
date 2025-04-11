//
//  CSVLoaderForPositioning.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 7/2/2025.
//

import Foundation

@MainActor
struct PositionCondition {
    
    let status: String
    let condition1: String
    let condition2: String
    let condition3: String
    let condition4: String
    let condition5: String
    let condition6: String
    
//    static var gestureFeatureCompleted: Bool = false // Used to switch between technique in experiment 1 and 2
    
    static var lastUsedPositionConditionIndex: Int = -1
    
    static var lastUsedSafeIndex: Int = -1
    
    static var positionConditionsCompleted: Bool = false // Used to show 'next' button once all conditions are done
    
    static var positionGestureOrder :  RotationOrder = .nonRotatingFirst
    
    //Only for printing in csv
    static var currentDistance: Distance = .near
    
    //Only for printing in csv
    static var currentDirection: Direction = .horizontal
    
    
    enum RotationOrder{
        case rotatingFirst
        case nonRotatingFirst
        
        var list: [PositioningGesture] {
            switch self {
            case .rotatingFirst:
                return [.rotating, .notRotating]
            case .nonRotatingFirst:
                return [.notRotating, .rotating]
            }
        }
    }
        
//    static var positionSwapTechnique: Bool = false // This var will swap technique, so that technique is implemented to Balanced Latin Square by half order
    
    enum PositioningGesture {
        case rotating
        case notRotating
    }
    
    enum Distance {
        case near
        case far
    }
    
    enum Direction {
        case horizontal
        case vertical
        case diagonal
        case none
    }
    
    /// Load `Landmark`s from CSV file in the app bundle.
    /// - Returns: Loaded landmarks.
    static func loadPositionConditions() throws -> [PositionCondition] {
//        Works for read-only:
//        guard let url = Bundle.main.url(forResource: "Positioning", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Positioning.csv' not found in the app bundle."])
//        }
        
//        Works for simulator only:
//        let currentFileURL = URL(fileURLWithPath: #file)
//        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
//        let csvFileURL = currentDirectoryURL.appendingPathComponent("Positioning.csv")
//        let csvFileURL = documentsDir.appendingPathComponent("Positioning.csv")
        
//        Below works for the headset itself:
        let fileName = "Positioning.csv"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let csvFileURL = documentDirectory.appending(path: fileName, directoryHint: .notDirectory)

        
        let data = try String(contentsOf: csvFileURL, encoding: .utf8)
        var positionConditions: [PositionCondition] = []
        let rows = data.split(whereSeparator: \.isNewline).dropFirst().filter { !$0.isEmpty }
        //let rows = data.split(separator: "\n").dropFirst() // Skip header row
        for (index, row) in rows.enumerated() {
            let columns = row.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard columns.count == 7
            else {
                throw NSError(domain: "CSVLoader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid row format in CSV: \(row)"])
            }

            let positionCondition = PositionCondition(status: columns[0],
                                                      condition1: columns[1],
                                                      condition2: columns[2],
                                                      condition3: columns[3],
                                                      condition4: columns[4],
                                                      condition5: columns[5],
                                                      condition6: columns[6]
            )
            positionConditions.append(positionCondition)
            
            if index.isMultiple(of: 2) && columns[0] == "Active" {
                positionGestureOrder = .rotatingFirst
            }
        }
        return positionConditions
    }
    
    static func savePositionConditions(positionConditions: [PositionCondition]) throws {
//        guard let url = Bundle.main.url(forResource: "Positioning", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Positioning.csv' not found in the directory."])
//        }
        
//        Below works for the headset itself:
        let fileName = "Positioning.csv"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let csvFileURL = documentDirectory.appending(path: fileName, directoryHint: .notDirectory)
//        Below works for simulator only:
//        let currentFileURL = URL(fileURLWithPath: #file)
//        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
//        let csvFileURL = currentDirectoryURL.appendingPathComponent("Positioning.csv")

        guard let activeIndex = positionConditions.firstIndex(where: { $0.status == "Active" }) else {
            throw NSError(domain: "CSVLoader", code: 3, userInfo: [NSLocalizedDescriptionKey: "No active condition found"])
        }

        var updatedConditions = positionConditions

        updatedConditions[activeIndex] = PositionCondition(status: "Inactive",
                                                           condition1: positionConditions[activeIndex].condition1,
                                                           condition2: positionConditions[activeIndex].condition2,
                                                           condition3: positionConditions[activeIndex].condition3,
                                                           condition4: positionConditions[activeIndex].condition4,
                                                           condition5: positionConditions[activeIndex].condition5,
                                                           condition6: positionConditions[activeIndex].condition6)

        let nextIndex = (activeIndex + 1) % positionConditions.count

        updatedConditions[nextIndex] = PositionCondition(status: "Active",
                                                         condition1: positionConditions[nextIndex].condition1,
                                                         condition2: positionConditions[nextIndex].condition2,
                                                         condition3: positionConditions[nextIndex].condition3,
                                                         condition4: positionConditions[nextIndex].condition4,
                                                         condition5: positionConditions[nextIndex].condition5,
                                                         condition6: positionConditions[nextIndex].condition6)
        
        let csvHeader = "status,condition1,condition2,condition3,condition4,condition5,condition6\n"
        let csvRows = updatedConditions.map { "\($0.status),\($0.condition1),\($0.condition2),\($0.condition3),\($0.condition4),\($0.condition5),\($0.condition6)" }
        let csvString = csvHeader + csvRows.joined(separator: "\n")

        try csvString.write(to: csvFileURL, atomically: true, encoding: .utf8)
    }
    
    static func positionConditionsGetter(for positionConditions: [PositionCondition], lastUsedIndex: Int) -> (rotatingGlobeList: [PositioningGesture], distance: Distance, direction: Direction) {
//        var activeSubject: ScalingCondition?
        let rotatingGlobeList = positionGestureOrder.list
//        let rotatingGlobe: RotatingGlobe = gestureFeatureCompleted ? rotatingGlobeList[0] : rotatingGlobeList[1]
        var distance: Distance = .near
        var direction: Direction = .none
        
        guard let activeSubject = positionConditions.first(where: { $0.status == "Active"}) else {
            print("No active subject exists.")
            return ([.notRotating, .rotating], .near, .none)
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
                               activeSubject.condition2,
                               activeSubject.condition3,
                               activeSubject.condition4,
                               activeSubject.condition5,
                               activeSubject.condition6]
        
        if conditionValues.isEmpty {
            print("No conditions available.")
            return ([.notRotating, .rotating], .near, .none)
        }
        
        // safeguard the index
        var safeIndex = min(max(lastUsedIndex, 0), conditionValues.count - 1)
        
        if lastUsedSafeIndex == safeIndex {
            safeIndex += 1
        }
        
        let selectedCondition = conditionValues[safeIndex]
        
        lastUsedSafeIndex = safeIndex
                
//        for condition in conditionValues {
        switch selectedCondition {
        case "A":
            distance = .near; direction = .horizontal
        case "B":
            distance = .near; direction = .vertical
        case "C":
            distance = .near; direction = .diagonal
        case "D":
            distance = .far; direction = .horizontal
        case "E":
            distance = .far; direction = .vertical
        case "F":
            distance = .far; direction = .diagonal
        default:
            break
        }
        
        currentDistance = distance
        currentDirection = direction
        
        return (rotatingGlobeList, distance, direction)
    }
    
    static func positionConditionsSetter(for positionConditions: [PositionCondition], lastUsedIndex: inout Int) {
        guard let activeSubject = positionConditions.first(where: { $0.status == "Active"}) else {
            print("No active subject exists.")
            return
        }
        
        let conditionValues = [activeSubject.condition1,
                               activeSubject.condition2,
                               activeSubject.condition3,
                               activeSubject.condition4,
                               activeSubject.condition5,
                               activeSubject.condition6]
        
        if conditionValues.isEmpty {
            print("No conditions available.")
        }
        
        if (lastUsedIndex + 1) == conditionValues.count {
//            gestureFeatureCompleted.toggle()
            positionConditionsCompleted = true
            lastUsedIndex = -1
        } else {
            lastUsedIndex += 1
        }
        
    }
}
