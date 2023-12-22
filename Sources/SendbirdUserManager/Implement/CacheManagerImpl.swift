//
//  CacheManagerImpl.swift
//
//
//  Created by 김재석 on 12/18/23.
//

import Foundation

class CacheManagerImpl<T: Codable>: CacheManager {
    
    private let cacheManagerQueue = DispatchQueue(label: "com.SendbirdUserManager .cacheManagerQueue", attributes: .concurrent)
    private var memoryCache: [String : T] = [:]
    private let diskCacheDirectory: URL
    
    init() {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheDirectory = cacheDirectory.appendingPathComponent("GenericDiskCache")
        
        if !FileManager.default.fileExists(atPath: diskCacheDirectory.path) {
            try? FileManager.default.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

extension CacheManagerImpl{
    
    func upsertToMemoryCache(
        key: String,
        value: T
    ) {
        
        cacheManagerQueue.async(flags: .barrier) { [self] in
            
            memoryCache[key] = value
        }
    }
    
    func getFromMemoryCache(
        key: String
    ) -> T? {
        
        var result: T?
        
        cacheManagerQueue.sync {
            
            result = memoryCache[key]
        }
        
        return result
    }
}

extension CacheManagerImpl{
    
    func upsertToDiskCache(
        key: String,
        value: T
    ) {
        
        let fileURL = diskCacheDirectory.appendingPathComponent(key)
        let encoder = JSONEncoder()
        
        if let encodedData = try? encoder.encode(value) {
            
            cacheManagerQueue.async(flags: .barrier) {
                
                try? encodedData.write(to: fileURL)
            }
        }
    }
    
    func getFromDiskCache(
        key: String
    ) -> T? {
        
        var result: T?
    
        cacheManagerQueue.sync {
         
            let fileURL = diskCacheDirectory.appendingPathComponent(key)
            let decoder = JSONDecoder()
            
            if let data = try? Data(contentsOf: fileURL),
                let decodedValue = try? decoder.decode(T.self, from: data) {
                
                result = decodedValue
                
            }
        }
        
        return result
    }
}

extension CacheManagerImpl{
    
    func getAllFromMemoryCache() -> [T] {
        
        var results: [T] = []
        
        cacheManagerQueue.sync {
            
            results = Array(memoryCache.values)
        }
        
        return results
    }
    
    func getAllFromDiskCache() -> [T] {
        
        var results: [T] = []
        
        do {

            try? cacheManagerQueue.sync {
                
                let fileURLs = try FileManager.default.contentsOfDirectory(at: diskCacheDirectory, includingPropertiesForKeys: nil)
                let decoder = JSONDecoder()
                
                results = fileURLs.compactMap { fileURL in
                    
                    guard let data = try? Data(contentsOf: fileURL),
                          let decodedValue = try? decoder.decode(T.self, from: data) else {
                        
                        return nil
                    }
                    
                    return decodedValue
                }
            }
            
            return results
            
        } catch {
            
            return results
            
        }
    }
}
