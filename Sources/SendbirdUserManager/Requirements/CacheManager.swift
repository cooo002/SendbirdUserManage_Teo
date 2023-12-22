//
//  CacheManager.swift
//
//
//  Created by 김재석 on 12/18/23.
//

import Foundation

protocol CacheManager {
    
    associatedtype T
    
    func upsertToMemoryCache(key: String, value: T)
    func upsertToDiskCache(key: String, value: T)
    func getFromMemoryCache(key: String) -> T?
    func getFromDiskCache(key: String) -> T?
    func getAllFromMemoryCache() -> [T]
    func getAllFromDiskCache() -> [T]
}

