//
//  APIInterceptor.swift
//  APIModule
//  
//  Created by Daiki Fujimori on 2025/09/15
//  

import Foundation

public protocol APIInterceptor: Sendable {

    func adapt(_ urlRequest: URLRequest,
               completion: @escaping @Sendable (Result<URLRequest, any Error>) -> Void)

    func retry(_ request: APIRequest,
               dueTo error: any Error,
               completion: @escaping @Sendable (APIRetryResult) -> Void)
}

public struct APIRequest {

    public let statusCode: Int?
    public let retryCount: Int

    public init(statusCode: Int?, retryCount: Int) {
        self.statusCode = statusCode
        self.retryCount = retryCount
    }
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
