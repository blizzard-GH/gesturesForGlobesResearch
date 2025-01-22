//
//  ThrottledArray.swift
//  SimpleGlobe
//
//  Created by Bernhard Jenny on 22/1/2025.
//

import Combine
import Foundation

@MainActor
class ThrottledArray<Element> {
    private var array: [Element] = []
    private let appendSubject = PassthroughSubject<Element, Never>()
    private var cancellable: AnyCancellable?
    private let throttleInterval: TimeInterval

    init(throttleInterval: TimeInterval) {
        self.throttleInterval = throttleInterval
        cancellable = appendSubject
            .throttle(for: .seconds(throttleInterval), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] element in
                self?.array.append(element)
            }
    }

    func appendThrottled(_ element: Element) {
        appendSubject.send(element)
    }

    func append(_ element: Element) {
        array.append(element)
    }
    
    var elements: [Element] {
        array
    }
    
    var count: Int {
        array.count
    }
    
    var first: Element? {
        array.first
    }
    
    var last: Element? {
        array.last
    }
}
