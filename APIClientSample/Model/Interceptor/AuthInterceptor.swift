//
//  AuthInterceptor.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/09/15
//  

import Domain
import Foundation

// MARK: - AuthIntercepting

protocol AuthIntercepting: APIInterceptor {
    
    var statusCodesToHandle: [Int] { get }
    var headerAuthorization: String { get }
    var retryMaxCount: Int { get }
}

extension AuthIntercepting {
    
    var statusCodesToHandle: [Int] { [401] }
    var headerAuthorization: String { "Authorization" }
    var retryMaxCount: Int { 1 }
}

private enum AuthInterceptorKey: DependencyKey {
    
    static let liveValue: AuthIntercepting = AuthInterceptor { _ in  }
}

extension DependencyValues {
    
    var authInterceptor: AuthIntercepting {
        get { self[AuthInterceptorKey.self] }
        set { self[AuthInterceptorKey.self] = newValue }
    }
}

// MARK: - AuthInterceptor

struct AuthInterceptor {
    
    var tokenFetcher: @Sendable (@escaping (String?, HttpResponseStatus?) -> Void) -> Void
}

extension AuthInterceptor: AuthIntercepting {
    
    func adapt(_ urlRequest: URLRequest,
               completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void) {
        
        tokenFetcher { token, status in
            
            guard let token else {
                
                let fetchTokenError = AuthInterceptError.fetchTokenError(status)
                completion(.failure(fetchTokenError))
                return
            }
            
            var adaptedUrlRequest = urlRequest
            adaptedUrlRequest.headers[headerAuthorization] = token
            completion(.success(adaptedUrlRequest))
        }
    }
    
    func retry(_ request: APIRequest,
               dueTo error: any Error,
               completion: @escaping @Sendable (Domain.APIRetryResult) -> Void) {
        
        guard let statusCode = request.request.response?.statusCode,
              statusCodesToHandle.contains(statusCode) else {
            
            completion(.doNotRetry)
            return
        }
        
        guard request.request.retryCount < retryMaxCount else {
            
            completion(.doNotRetryWithError(AuthInterceptError.retryLimit))
            return
        }
        
        completion(.retry)
    }
}

enum AuthInterceptError: Equatable, Error {
    
    case fetchTokenError(HttpResponseStatus?)
    case retryLimit
}
