//
//  AttributeTable.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 25/9/2024.
//

import Foundation

/// A dictionary mapping  a key to a string, initialised from a CSV file.
struct AttributeTable {
    
    private let table: [Int: String]
    
    init(fileName: String) throws {
        let fileContent = try Self.loadFileFromBundle(filename: fileName, fileType: "csv")
        self.table = try Self.parseCSV(fileContent: fileContent)
    }
    
    func value(forKey key: Int) -> String? {
        table[key]
    }
    
    private static func loadFileFromBundle(filename: String, fileType: String) throws -> String {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: fileType) else {
            throw error("Cannot load CSV file with attribute table from the app bundle.")
        }
        return try String(contentsOf: fileURL, encoding: .utf8)
    }
    
    private static func parseCSV(fileContent: String) throws -> [Int: String] {
        var result: [Int: String] = [:]
        let rows = fileContent.split(separator: "\n")
        for row in rows {
            let columns = row.split(separator: ",")
            
            // Ensure there are exactly 2 columns (name, value)
            if columns.count == 2,
                let intValue = Int(columns[0].trimmingCharacters(in: .whitespaces)) {
                let name = String(columns[1].trimmingCharacters(in: .whitespaces))
                // Add the entry to the dictionary with the integer as the key and the name as the value
                result[intValue] = name
            } else {
                throw error("Invalid row format: \(row)")
            }
        }
        
        return result
    }
    
}
