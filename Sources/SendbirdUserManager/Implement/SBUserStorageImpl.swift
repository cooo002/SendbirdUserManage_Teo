//
//  SBUserStorageImpl.swift
//
//
//  Created by 김재석 on 12/18/23.
//


// 메모리에 있는 유저 정보 확인
import Foundation

class SBUserStorageImpl: SBUserStorage {

    private var cacheManager: CacheManagerImpl<SBUser>
    
    required init() {
        
        self.cacheManager = CacheManagerImpl<SBUser>()
    }
    
    func upsertUser(_ user: SBUser) {
        
        self.cacheManager.upsertToMemoryCache(key: user.userId, value: user)
        self.cacheManager.upsertToDiskCache(key: user.userId, value: user)
    }
    
    func getUsers() -> [SBUser] {
        
        let memoryCache = cacheManager.getAllFromMemoryCache()
        
        if !memoryCache.isEmpty{
            
            return memoryCache
        }
        
        let diskCache = cacheManager.getAllFromDiskCache()
        
        if !diskCache.isEmpty{
            
            return diskCache
        }
        
        return []
    }
    
    func getUsers(for nickname: String) -> [SBUser] {
    
        let memoryCache = cacheManager.getAllFromMemoryCache().filter { $0.nickname == nickname }
        
        if !memoryCache.isEmpty{
            
            return memoryCache
        }
        
        let diskCache = cacheManager.getAllFromDiskCache().filter { $0.nickname == nickname }
        
        if !diskCache.isEmpty{
            
            return diskCache
        }
        
        return []
    }
    
    func getUser(for userId: String) -> SBUser? {
        
        if let memoryCache = cacheManager.getFromMemoryCache(key: userId) {

            return memoryCache
        }
        
        if let diskCache = cacheManager.getFromDiskCache(key: userId) {
            
            cacheManager.upsertToMemoryCache(key: userId, value: diskCache)
            
            return diskCache
        }
        
        return nil
    }
}
