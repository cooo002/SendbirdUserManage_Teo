//
//  SendbirdUserManagerTests.swift
//  SendbirdUserManagerTests
//
//  Created by Sendbird
//

import XCTest
@testable import SendbirdUserManager

final class UserManagerTests: UserManagerBaseTests {
    
    override func userManagerType() -> SBUserManager.Type! {
        
        return SBUserManagerImpl.self
    }
}

final class UserStorageTests: UserStorageBaseTests {
    
    override func userStorageType() -> SBUserStorage.Type! {
        
        return SBUserStorageImpl.self
    }
}

final class NetworkClientTests: NetworkClientBaseTests {
    
    override func networkClientType() -> SBNetworkClient.Type! {
        
        return SBNetworkClientImpl.self
    }
}
