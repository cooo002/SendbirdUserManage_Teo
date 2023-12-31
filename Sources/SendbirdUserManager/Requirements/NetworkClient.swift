//
//  NetworkClient.swift
//  
//
//  Created by Sendbird
//

import Foundation



public protocol Request {
    associatedtype Response: Decodable
    
    var url: String { get set }
    var method: APIMethod { get set }
    var path: APIPath { get set }
    var parmater: String? { get set }
    var body: APIBody? { get set }
    var apiToken: String { get set }
}

public enum APIMethod: String{
    
    case GET
    case POST
    case PUT
    case DELETE
}

public enum APIPath{
    
    case user(userId: String?)
    
    var path: String{
        
        switch self {
            
        case .user(let userId):
            
            if let userId = userId{
                
                let userIdPath = "/\(userId)"
                
                return "/users\(userIdPath)"
            }
            
            return "/users"
        }
    }
}

public struct APIBody: Codable{
    
    let user_id: String
    let nickname: String?
    let profile_url: String?
}

struct APIRequest<T: Decodable>: Request{
    
    public typealias Response = T
    
    var url: String
    var method: APIMethod
    var path: APIPath
    var parmater: String?
    var body: APIBody?
    var apiToken: String
}

public struct APIResponseData: Codable{
    
    public var users: [SBUser]?
    public var next: String?
}

public protocol SBNetworkClient {
    init()
    
    /// 리퀘스트를 요청하고 리퀘스트에 대한 응답을 받아서 전달합니다
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    )
}
    
