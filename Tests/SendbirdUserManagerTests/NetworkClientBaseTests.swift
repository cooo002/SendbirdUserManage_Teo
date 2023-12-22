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
            request: APIRequest<SBUser>(
                url: url,
                method: .GET,
                path: .user,
                parmater: "",
                body: nil
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
