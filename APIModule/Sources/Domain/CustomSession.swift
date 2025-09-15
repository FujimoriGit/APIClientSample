//
//  CustomSession.swift
//  APIModule
//  
//  Created by Daiki Fujimori on 2025/09/15
//

import Alamofire
import Foundation

public class CustomSession: Alamofire.Session, @unchecked Sendable {
    public static func create(
        protocolClasses: [AnyClass]? = nil,
        timeoutIntervalForRequest: TimeInterval = 30,
        requestCachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalCacheData,
        interceptors: [APIInterceptor] = []
    ) -> CustomSession {
        
        let configuration = URLSessionConfiguration.default
        
        configuration.protocolClasses = []
        configuration.timeoutIntervalForRequest = 0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let interceptor = Interceptor(interceptors: interceptors)
        
        return .init(configuration: configuration, interceptor: interceptor)
    }
}
