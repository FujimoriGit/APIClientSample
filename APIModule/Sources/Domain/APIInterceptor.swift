//
//  APIInterceptor.swift
//  APIModule
//  
//  Created by Daiki Fujimori on 2025/09/15
//  

import Alamofire
import Foundation

public protocol APIInterceptor: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest,
               completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void)
    
    func retry(_ request: APIRequest,
               dueTo error: any Error,
               completion: @escaping @Sendable (APIRetryResult) -> Void)
}

extension APIInterceptor {
    
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void) {
        
        adapt(urlRequest, completion: completion)
    }

    func retry(_ request: Request,
               for session: Session,
               dueTo error: any Error,
               completion: @escaping @Sendable (RetryResult) -> Void) {
        
        retry(APIRequest(request: request), dueTo: error) { completion($0.retryResult) }
    }
}

public struct APIRequest {
    
    public let request: Request
}

public enum APIRetryResult: Sendable {
    /// Retry should be attempted immediately.
    case retry
    /// Retry should be attempted after the associated `TimeInterval`.
    case retryWithDelay(TimeInterval)
    /// Do not retry.
    case doNotRetry
    /// Do not retry due to the associated `Error`.
    case doNotRetryWithError(any Error)
}

extension APIRetryResult {
    var retryResult: RetryResult {
        switch self {
        case .retry: .retry
        case .retryWithDelay(let interval): .retryWithDelay(interval)
        case .doNotRetry: .doNotRetry
        case .doNotRetryWithError(let error): .doNotRetryWithError(error)
        }
    }
}
