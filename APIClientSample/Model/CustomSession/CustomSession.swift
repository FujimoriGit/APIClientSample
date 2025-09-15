//
//  CustomSession.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/09/15
//  

import Domain
import Foundation

extension CustomSession {
    
    static func make(
        protocolClasses: [AnyClass]? = nil,
        timeoutIntervalForRequest: TimeInterval = 30,
        requestCachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    ) -> CustomSession {
        
        @Dependency(\.authInterceptor) var authInterceptor
        
        return .create(
            protocolClasses: protocolClasses,
            timeoutIntervalForRequest: timeoutIntervalForRequest,
            requestCachePolicy: requestCachePolicy,
            interceptors: [authInterceptor]
        )
    }
}
