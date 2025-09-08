//
//  APIService.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/30
//  

import Domain
import Foundation

actor APIService {
    
    static let shared = APIService()
    
    @Dependency(\.apiProvider) private var apiProvider
    
    private init() {}
    
    func request<Response: Decodable>(
        _ target: APITargetType,
        completion: @escaping (Result<(Int?, Response?), APIError>
        ) -> Void) {
        
        apiProvider.request(target: target) { result in
            
            switch result {
                
            case .success(let response):
                
                do {
                    
                    let value = try JSONDecoder().decode(Response.self, from: response.data)
                    completion(.success((response.statusCode, value)))
                } catch {
                    
                    completion(.failure(.objectMapping(error, response)))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }
}

// MARK: - private method

private extension APIService {
    
    func getStatus(_ statusCode: Int) -> HttpResponseStatus {
        
        switch statusCode {
            
        case 200...299:
            return .success
            
        case 400...499:
            if case 401 = statusCode {
                
                return .tokenExpired
            }
            else {
                
                return .invalidRequest
            }
            
        case 500...599:
            return .serverError
            
        default:
            return .unknown
        }
    }
}

enum HttpResponseStatus: Equatable {
    
    /// 不明
    case unknown
    /// 200...299
    case success
    /// 400系
    case invalidRequest
    /// 401
    case tokenExpired
    ///  503
    case serverError
}
