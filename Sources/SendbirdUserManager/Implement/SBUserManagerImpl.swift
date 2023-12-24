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
    private var lastInitApplicationId: String?
    
    required init() {}
    
    func initApplication(applicationId: String, apiToken: String) {
        
        if lastInitApplicationId != applicationId {
            // 앱이 다르면 데이터 초기화
            userStorage.clearUserCacheData()
            lastInitApplicationId = applicationId
        }
        
        self.applicationId = applicationId
        self.apiToken = apiToken
    }
    
    func createUser(
        params: UserCreationParams,
        completionHandler: ((UserResult) -> Void)?
    ) {
        // Sendbird API 호출 및 캐시 로직 구현
        // completionHandler 호출
        
        if let apiToken = self.apiToken, let applicationId = self.applicationId {
            
            let url = "https://api-\(String(describing: applicationId)).sendbird.com/v3"
            let apiBody = APIBody(
                user_id: params.userId,
                nickname: params.nickname,
                profile_url: params.profileURL
            )
            
            SBNetworkClientImpl().request(
                request: APIRequest<SBUser>(
                    url: url,
                    method: .POST,
                    path: .user(userId: nil),
                    parmater: "",
                    body: apiBody,
                    apiToken: apiToken
                )
            ) { [weak self] result in
                
                switch result {
                    
                case .success(let user):
                    print("createUser \(user)")
                    self?.userStorage.upsertUser(user)
                    
                    completionHandler?(.success(user))
                    
                case .failure(let failure):
                    print("createUser fail\(failure)")
                    completionHandler?(.failure(failure))
                }
            }
        }
    }
    
    func createUsers(
        params: [UserCreationParams],
        completionHandler: ((UsersResult) -> Void)?
    ) {
        
        // Sendbird API 호출 및 캐시 로직 구현
        // completionHandler 호출
        
        guard params.count > 0 else {
             // 파라미터 리스트가 비어있으면 생성할 사용자가 없습니다.
             completionHandler?(.failure(UserManagerError.emptyParams))
             return
         }
         
         // 사용자 생성 제한을 확인합니다.
         let rateLimit = 1.0 // 초당 사용자 생성 제한
         let maxUsersPerRequest = 10
         let totalRequests = params.count
         
         // 성공적으로 생성된 사용자를 추적하는 배열
         var successfulUsers: [SBUser] = []
         
         // 각 요청의 에러를 추적하는 배열
         var requestErrors: [Error] = []
         
         // 요청을 순차적으로 수행하기 위한 큐
         let requestQueue = DispatchQueue(label: "createUsersQueue")
         
         // 요청을 순차적으로 처리합니다.
         for (index, param) in params.enumerated() {
             
             requestQueue.asyncAfter(deadline: .now() + Double(index) * 1.0 / rateLimit) {
                 // 단일 createUsers API 요청을 수행합니다.
                 
                 self.createUser(params: param) { result in
                     
                     switch result {
                         
                     case .success(let user):
                         
                         successfulUsers.append(user)
                         
                     case .failure(let error):
                         
                         requestErrors.append(error)
                         
                     }
                     
                     // 모든 요청이 완료되면 결과를 처리합니다.
                     if successfulUsers.count + requestErrors.count == totalRequests {
                         
                         if requestErrors.isEmpty {
                             
                             completionHandler?(.success(successfulUsers))
                             
                         } else {
                             
                             completionHandler?(.failure(UserManagerError.createPartialFailure))
                             
                         }
                     }
                 }
             }
         }
    }
    
    func updateUser(
        params: UserUpdateParams,
        completionHandler: ((UserResult) -> Void)?
    ) {
        
        // Sendbird API 호출 및 캐시 업데이트 로직 구현
        // completionHandler 호출
        
        if let apiToken = self.apiToken, let applicationId = self.applicationId{
            
            let url = "https://api-\(String(describing: applicationId)).sendbird.com/v3"
            let apiBody = APIBody(
                user_id: params.userId,
                nickname: params.nickname,
                profile_url: params.profileURL
            )
            
            SBNetworkClientImpl().request(
                request: APIRequest<SBUser>(
                    url: url,
                    method: .PUT,
                    path: .user(userId: params.userId),
                    parmater: "",
                    body: apiBody,
                    apiToken: apiToken
                )
            ) { [weak self] result in
                
                switch result {
                    
                case .success(let user):
                    
                    self?.userStorage.upsertUser(user)
                    
                    completionHandler?(.success(user))
                    
                case .failure(let failure):
                    
                    completionHandler?(.failure(failure))
                }
            }
        }
    }
    
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?){
        
        // 캐시 확인 및 Sendbird API 호출, 캐시 업데이트 로직 구현
        // completionHandler 호출
        
        if let user = userStorage.getUser(for: userId){
            
            completionHandler?(.success(user))
            
        }else{
            
            if let apiToken = self.apiToken, let applicationId = self.applicationId {
                
                let url = "https://api-\(String(describing: applicationId)).sendbird.com/v3"
                let userId = ""
                SBNetworkClientImpl().request(
                    request: APIRequest<SBUser>(
                        url: url,
                        method: .GET,
                        path: .user(userId: userId),
                        parmater: "",
                        body: nil,
                        apiToken: apiToken
                    )
                ) { [weak self] result in
                    
                    switch result {
                        
                    case .success(let user):
                        
                        self?.userStorage.upsertUser(user)
                        
                        completionHandler?(.success(user))
                        
                    case .failure(let failure):
                        
                        completionHandler?(.failure(failure))
                    }
                }
            }
        }
    }
    
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        // Sendbird API 호출 및 캐시 로직 구현
        // completionHandler 호출
        if let apiToken = self.apiToken, let applicationId = self.applicationId {
            
            let url = "https://api-\(String(describing: applicationId)).sendbird.com/v3"
            let paramater = "?limit=100&nickname=\(nicknameMatches)"
            
            SBNetworkClientImpl().request(
                request: APIRequest<[SBUser]>(
                    url: url,
                    method: .GET,
                    path: .user(userId: nil),
                    parmater: paramater,
                    body: nil,
                    apiToken: apiToken
                )
            ) { [weak self] result in
                
                switch result {
                    
                case .success(let users):
                    
                    users.forEach { user in
                        
                        self?.userStorage.upsertUser(user)
                    }
                    
                    completionHandler?(.success(users))
                    
                case .failure(let failure):
                    
                    completionHandler?(.failure(failure))
                }
            }
        }
    }
}

