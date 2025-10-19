//
//  URLCache+ImageCache.swift
//  ExpenseTracker
//
//  Created by Rifqi Fadhlillah on 21/08/25.
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(
        memoryCapacity: 512.megabytes(),
        diskCapacity: 2.gigabytes()
    )
}

private extension Int {
    func kilobytes() -> Int {
        self * 1024 * 1024
    }

    func megabytes() -> Int {
        self.kilobytes() * 1024
    }

    func gigabytes() -> Int {
        self.megabytes() * 1024
    }
}
