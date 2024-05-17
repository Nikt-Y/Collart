//
//  URLCache+imageCache.swift
//  Collart
//
//  Created by Nik Y on 09.05.2024.
//

import Foundation

extension URLCache {
    static let imageCache = URLCache(memoryCapacity: 100_000_000, diskCapacity: 1_000_000_000)
}
