//
//  Matcher.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 18/1/2025.
//

import Foundation
import RealityKit

@MainActor
protocol Matcher {
    func isMatching(_ transform: Transform) -> Bool
    func accuracy(of transform: Transform) -> Float
}
