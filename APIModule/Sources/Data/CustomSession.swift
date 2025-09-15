//
//  CustomSession.swift
//  APIModule
//
//  Created by Daiki Fujimori on 2025/09/15
//

import Alamofire
import Foundation
import Domain

public final class CustomSession: Alamofire.Session, @unchecked Sendable {
    public static func create(
        protocolClasses: [AnyClass]? = nil,
        timeoutIntervalForRequest: TimeInterval = 30,
        requestCachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalCacheData,
        interceptors: [APIInterceptor] = []
    ) -> CustomSession {

        let configuration = URLSessionConfiguration.default

        configuration.protocolClasses = protocolClasses
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest
        configuration.requestCachePolicy = requestCachePolicy

        let requestInterceptors = interceptors.map { InterceptorAdapter($0) }
        let interceptor = Interceptor(interceptors: requestInterceptors)

        return .init(configuration: configuration, interceptor: interceptor)
    }
}

private final class InterceptorAdapter: RequestInterceptor {
    private let base: APIInterceptor

    init(_ base: APIInterceptor) {
        self.base = base
    }

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        base.adapt(urlRequest, completion: completion)
    }

    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        let apiRequest = APIRequest(statusCode: request.response?.statusCode,
                                    retryCount: request.retryCount)
        base.retry(apiRequest, dueTo: error) { completion($0.retryResult) }
    }
}

private extension APIRetryResult {
    var retryResult: RetryResult {
        switch self {
        case .retry:
            return .retry
        case .retryWithDelay(let interval):
            return .retryWithDelay(interval)
        case .doNotRetry:
            return .doNotRetry
        case .doNotRetryWithError(let error):
            return .doNotRetryWithError(error)
        }
    }
}
