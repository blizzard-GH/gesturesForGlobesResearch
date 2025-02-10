//
//  CaseIterable+Next.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 28/11/2024.
//

import Foundation

/// https://stackoverflow.com/a/51104162
extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}
