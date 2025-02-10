//
//  CSVLoader.swift
//  SimpleGlobe
//
//  Created by Faisal Agung Abdillah on 7/2/2025.
//

import Foundation


struct ScalingCondition {
    let status: String
    let condition1: String
    let condition2: String
    let condition3: String
    let condition4: String
    
    /// Load `Landmark`s from CSV file in the app bundle.
    /// - Returns: Loaded landmarks.
    static func loadScalingConditions() throws -> [ScalingCondition] {
//        guard let url = Bundle.main.url(forResource: "Scaling", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Scaling.csv' not found in the directory."])
//        }
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
        let csvFileURL = currentDirectoryURL.appendingPathComponent("Scaling.csv")
        
        let data = try String(contentsOf: csvFileURL, encoding: .utf8)
        var scalingConditions: [ScalingCondition] = []
        let rows = data.split(whereSeparator: \.isNewline).dropFirst().filter { !$0.isEmpty }
        //let rows = data.split(separator: "\n").dropFirst() // Skip header row
        for row in rows {
            let columns = row.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            guard columns.count == 5
            else {
                throw NSError(domain: "CSVLoader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid row format in CSV: \(row)"])
            }
            let scalingCondition = ScalingCondition(status: columns[0],
                                                    condition1: columns[1],
                                                    condition2: columns[2],
                                                    condition3: columns[3],
                                                    condition4: columns[4])
            scalingConditions.append(scalingCondition)
        }
        return scalingConditions
    }
    
    static func saveScalingConditions(scalingConditions: [ScalingCondition]) throws {
//        guard let url = Bundle.main.url(forResource: "Scaling", withExtension: "csv") else {
//            throw NSError(domain: "CSVLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "CSV file 'Scaling.csv' not found in the app bundle."])
//        }
        let currentFileURL = URL(fileURLWithPath: #file)
        let currentDirectoryURL = currentFileURL.deletingLastPathComponent()
        let csvFileURL = currentDirectoryURL.appendingPathComponent("Scaling.csv")

        guard let activeIndex = scalingConditions.firstIndex(where: { $0.status == "Active" }) else {
            throw NSError(domain: "CSVLoader", code: 3, userInfo: [NSLocalizedDescriptionKey: "No active condition found"])
        }

        var updatedConditions = scalingConditions

        updatedConditions[activeIndex] = ScalingCondition(status: "Inactive",
                                                          condition1: scalingConditions[activeIndex].condition1,
                                                          condition2: scalingConditions[activeIndex].condition2,
                                                          condition3: scalingConditions[activeIndex].condition3,
                                                          condition4: scalingConditions[activeIndex].condition4)

        let nextIndex = (activeIndex + 1) % scalingConditions.count

        updatedConditions[nextIndex] = ScalingCondition(status: "Active",
                                                        condition1: scalingConditions[nextIndex].condition1,
                                                        condition2: scalingConditions[nextIndex].condition2,
                                                        condition3: scalingConditions[nextIndex].condition3,
                                                        condition4: scalingConditions[nextIndex].condition4)

        let csvHeader = "status,condition1,condition2,condition3,condition4\n"
        let csvRows = updatedConditions.map { "\($0.status),\($0.condition1),\($0.condition2),\($0.condition3),\($0.condition4)" }
        let csvString = csvHeader + csvRows.joined(separator: "\n")

        try csvString.write(to: csvFileURL, atomically: true, encoding: .utf8)
    }
    
    static func scalingConditionMapper(for scalingConditions: [ScalingCondition]) -> (globeMoving: Bool, smallToLarge: Bool) {
//        var activeSubject: ScalingCondition?
        var globeMoving: Bool = false
        var smallToLarge: Bool = false
        
        
        guard let activeSubject = scalingConditions.first(where: { $0.status == "Active"}) else {
            print("No active subject exists.")
            return (false, false)
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
                           activeSubject.condition4]
        
//        for condition in conditionValues {
        conditionValues.forEach { condition in
            switch condition {
            case "A":
                globeMoving = false
                smallToLarge = false
            case "B" :
                globeMoving = false
                smallToLarge = true
            case "C" :
                globeMoving = true
                smallToLarge = false
            case "D" :
                globeMoving = true
                smallToLarge = true
            default:
                break
            }
        }
        return (globeMoving, smallToLarge)
    }
}
