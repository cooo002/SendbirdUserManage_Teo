//
//  SBNetworkClientImpl.swift
//
//
//  Created by 김재석 on 12/18/23.
//


import Foundation
import UIKit

class SBNetworkClientImpl: SBNetworkClient {
    
    required init() {}
    
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    ) {
        let urlStr = request.url + request.path.rawValue + (request.parmater ?? "")
        
        guard let url = URL(string: urlStr) else {
            completionHandler(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue(
            "application/json; charset=utf8",
            forHTTPHeaderField: "Content-Type"
        )
        urlRequest.setValue(
            "275b933f8389c107b0be683c4b63ff209a11bdf1",
            forHTTPHeaderField: "Api-Token"
        )
        
        do {
            // Encodable 모델을 JSON 데이터로 변환
            if let requestBody = request.body {
                let jsonData = try JSONEncoder().encode(requestBody)
                urlRequest.httpBody = jsonData
            }
        } catch {
            // JSON 변환 실패
            completionHandler(.failure(error))
            return
        }
        
        let group = DispatchGroup()
        group.enter()
        
        // URLSession을 사용하여 네트워크 요청
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            // 네트워크 요청의 응답 처리
            if let error = error {
                completionHandler(.failure(error))
            } else if let data = data {
                do {
                    
                    // 서버 응답 데이터를 디코드
                    let decodedResponse = try JSONDecoder().decode(R.Response.self, from: data)
                    
                    completionHandler(.success(decodedResponse))
                    
                } catch {
                    // JSON 디코딩 실패
                    completionHandler(.failure(error))
                }
            }
            
            defer {
                group.leave()
            }
        }
        
        // 네트워크 요청 시작
        task.resume()
        
        // 비동기 작업이 완료될 때까지 대기
        group.wait()
    }
}

