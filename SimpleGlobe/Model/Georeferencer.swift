//
//  Georeferencer.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 25/9/2024.
//

import Foundation
import SwiftUI

/// Extracts a code for a geographic location from a grid.
struct Georeferencer {
    let grid: [[Int16]]
    let columns: Int
    let rows: Int
    
    /// Initializer
    /// - Parameters:
    ///   - fileName: Name of the file containing a geographic grid with integer codes in the app bundle. Row-first ASCII format.
    ///   - fileType: File extension.
    ///   - columns: Number of columns of the geographic grid.
    ///   - rows: Number of rows of the geographic grid.
    init(fileName: String, fileType: String = "asc", columns: Int, rows: Int) throws {
        let fileContent = try Self.loadFileFromBundle(filename: fileName, fileType: fileType)
        self.grid = try Self.parseGrid(from: fileContent, columns: columns, rows: rows)
        self.columns = columns
        self.rows = rows
    }
    
    /// Returns a code for a geographic location.
    /// - Parameters:
    ///   - lat: Latitude.
    ///   - lon: Longitude.
    /// - Returns: Code.
    func geocode(lat: Angle, lon: Angle) -> Int {
        var row = Int((1 - (lat.degrees / 90)) / 2 * (Double(rows) - 1).rounded())
        row = min(max(row, 0), rows - 1)
        
        var col = Int((1 + (lon.degrees / 180)) / 2 * (Double(columns) - 1).rounded())
        col = min(max(col, 0), columns - 1)
        
        return Int(grid[row][col])
    }
    
    private static func loadFileFromBundle(filename: String, fileType: String) throws -> String {
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: fileType) else {
            throw error("Cannot load georeference file from the app bundle.")
        }
        return try String(contentsOf: fileURL, encoding: .utf8)
    }
    
    private static func parseGrid(from fileContent: String, columns: Int, rows: Int) throws -> [[Int16]] {
        var grid: [[Int16]] = []
        let rowContent = fileContent.split(separator: "\n")
        guard rowContent.count == rows else {
            throw error("Grid has an unexpected number of rows.")
        }
        for row in rowContent {
            let values = row.split(separator: " ").compactMap { Int16($0) }
            guard values.count == columns else {
                throw error("Row has an unexpected number of columns.")
            }
            grid.append(values)
        }
        return grid
    }
    
}
