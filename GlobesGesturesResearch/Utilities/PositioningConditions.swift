//
//  CSVLoaderForPositioning.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 7/2/2025.
//

import Foundation


struct PositionCondition {
    let status: String
    let condition1: String
    let condition2: String
    let condition3: String
    let condition4: String
    let condition5: String
    let condition6: String
    let condition7: String
    let condition8: String
    
    enum Distance {
        case near
        case far
    }
    
    enum Movement {
        case horizontal
        case vertical
        case diagonalUp
        case diagonalDown
        case none
    }
    
    /// Load `Landmark`s from CSV file in the app bundle.
    /// - Returns: Loaded landmarks.
    static func loadPositionConditions() throws -> [PositionCondition] {
//        guard let url = Bundle.main.url(forResource: "Positioning", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Positioning.csv' not found in the app bundle."])
//        }
        
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
        let csvFileURL = currentDirectoryURL.appendingPathComponent("Positioning.csv")
        
        let data = try String(contentsOf: csvFileURL, encoding: .utf8)
        var positionConditions: [PositionCondition] = []
        let rows = data.split(whereSeparator: \.isNewline).dropFirst().filter { !$0.isEmpty }
        //let rows = data.split(separator: "\n").dropFirst() // Skip header row
        for row in rows {
            let columns = row.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard columns.count == 9
            else {
                throw NSError(domain: "CSVLoader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid row format in CSV: \(row)"])
            }

            let positionCondition = PositionCondition(status: columns[0],
                                                      condition1: columns[1],
                                                      condition2: columns[2],
                                                      condition3: columns[3],
                                                      condition4: columns[4],
                                                      condition5: columns[5],
                                                      condition6: columns[6],
                                                      condition7: columns[7],
                                                      condition8: columns[8]
            )
            positionConditions.append(positionCondition)
        }
        return positionConditions
    }
    
    static func savePositionConditions(positionConditions: [PositionCondition]) throws {
//        guard let url = Bundle.main.url(forResource: "Positioning", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Positioning.csv' not found in the directory."])
//        }
        
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
        let csvFileURL = currentDirectoryURL.appendingPathComponent("Positioning.csv")

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
                                                           condition6: positionConditions[activeIndex].condition6,
                                                           condition7: positionConditions[activeIndex].condition7,
                                                           condition8: positionConditions[activeIndex].condition8)

        let nextIndex = (activeIndex + 1) % positionConditions.count

        updatedConditions[nextIndex] = PositionCondition(status: "Active",
                                                         condition1: positionConditions[nextIndex].condition1,
                                                         condition2: positionConditions[nextIndex].condition2,
                                                         condition3: positionConditions[nextIndex].condition3,
                                                         condition4: positionConditions[nextIndex].condition4,
                                                         condition5: positionConditions[nextIndex].condition5,
                                                         condition6: positionConditions[nextIndex].condition6,
                                                         condition7: positionConditions[nextIndex].condition7,
                                                         condition8: positionConditions[nextIndex].condition8)
        
        let csvHeader = "status,condition1,condition2,condition3,condition4,condition5,condition6,condition7,condition8\n"
        let csvRows = updatedConditions.map { "\($0.status),\($0.condition1),\($0.condition2),\($0.condition3),\($0.condition4),\($0.condition5),\($0.condition6),\($0.condition7),\($0.condition8)" }
        let csvString = csvHeader + csvRows.joined(separator: "\n")

        try csvString.write(to: csvFileURL, atomically: true, encoding: .utf8)
    }
    
    static func positionConditionMapper(for positionConditions: [PositionCondition]) -> (distance: Distance, movement: Movement){
//        var activeSubject: ScalingCondition?
        var distance: Distance = .near // Default value
        var movement: Movement = .none // Default value
        
        guard let activeSubject = positionConditions.first(where: { $0.status == "Active"}) else {
            print("No active subject exists.")
            return (.near, .none)
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
                               activeSubject.condition6,
                               activeSubject.condition7,
                               activeSubject.condition8]
        
//        for condition in conditionValues {
        conditionValues.forEach { condition in
            switch condition {
            case "A": distance = .near; movement = .horizontal
            case "B": distance = .near; movement = .vertical
            case "C": distance = .near; movement = .diagonalUp
            case "D": distance = .near; movement = .diagonalDown
            case "E": distance = .far; movement = .horizontal
            case "F": distance = .far; movement = .vertical
            case "G": distance = .far; movement = .diagonalUp
            case "H": distance = .far; movement = .diagonalDown
            default:
                break
            }
        }
        return (distance, movement)
    }
}
