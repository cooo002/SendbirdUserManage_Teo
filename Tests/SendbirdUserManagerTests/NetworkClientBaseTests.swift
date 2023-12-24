//
//  NetworkClientBaseTests.swift
//
//
//  Created by 김재석 on 12/20/23.
//

import Foundation
import XCTest
@testable import SendbirdUserManager

open class NetworkClientBaseTests: XCTestCase {

    open func networkClientType() -> SBNetworkClient.Type! {
        return SBNetworkClientImpl.self
    }
    
    public func testNetwork(){
        
        let network = self.networkClientType().init()
        let url = "https://api-A7D574F1-40DD-4B8E-9D73-9317BA74E65B.sendbird.com/v3"
    
        network.request(
            request: APIRequest<APIResponseData>(
                url: url,
                method: .GET,
                path: .user(userId: nil),
                parmater: "",
                body: nil, 
                apiToken: "275b933f8389c107b0be683c4b63ff209a11bdf1"
            )
        ) { result in

            switch result {
                
            case .success(let success):
                
                print("User 생성 성공: \(success)")
            
            case .failure(let failure):
                
                print("User 생성 실패: \(failure)")
                
            }
        }
    }
    
    public func testPostNetwork(){
        
        let network = self.networkClientType().init()
        let url = "https://api-A7D574F1-40DD-4B8E-9D73-9317BA74E65B.sendbird.com/v3"
        let params = APIBody(user_id: "dfdf", nickname: "John Doe", profile_url: nil)
        
        network.request(
            request: APIRequest<SBUsertests>(
                url: url,
                method: .POST,
                path: .user(userId: nil),
                parmater: "",
                body: params,
                apiToken: "275b933f8389c107b0be683c4b63ff209a11bdf1"
            )
        ) { result in

            switch result {
                
            case .success(let success):
                
                print("User 생성 성공: \(success)")
            
            case .failure(let failure):
                
                print("User 생성 실패: \(failure)")
                
            }
        }
    }
}
