//
//  SBUserManagerImpl.swift
//
//
//  Created by 김재석 on 12/18/23.
//

import Foundation

class SBUserManagerImpl: SBUserManager {
    
    var networkClient: SBNetworkClient = SBNetworkClientImpl()
    var userStorage: SBUserStorage = SBUserStorageImpl()
    
    private var applicationId: String?
    private var apiToken: String?
    private var usersCache: [String: SBUser] = [:]
    private var lastInitApplicationId: String?
    
    required init() {}
    
    func initApplication(applicationId: String, apiToken: String) {
        
        if lastInitApplicationId != applicationId {
            // 앱이 다르면 데이터 초기화
            usersCache.removeAll()
            lastInitApplicationId = applicationId
        }
        
        self.applicationId = applicationId
        self.apiToken = apiToken
    }
    
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        // Sendbird API 호출 및 캐시 로직 구현
        // completionHandler 호출
        
        
    }
    
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        // Sendbird API 호출 및 캐시 로직 구현
        // completionHandler 호출
    }
    
    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        // Sendbird API 호출 및 캐시 업데이트 로직 구현
        // completionHandler 호출
    }
    
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        // 캐시 확인 및 Sendbird API 호출, 캐시 업데이트 로직 구현
        // completionHandler 호출
    }
    
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        // Sendbird API 호출 및 캐시 로직 구현
        // completionHandler 호출
    }
}
