//
//  APIRequesting.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/23
//  

import Alamofire
import Foundation
import Moya

// MARK: - APIRequesting

public protocol APIRequesting: Sendable {
    
    var session: CustomSession { get }
    
    func request(
        target: APITargetType,
        callbackQueue: DispatchQueue?,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    )
}

public extension APIRequesting {
    
    func request(
        target: APITargetType,
        callbackQueue: DispatchQueue? = nil,
        completion: @escaping (Result<APIResponse, APIError>) -> Void
    ) {
        
        request(target: target, callbackQueue: callbackQueue, completion: completion)
    }
}

// MARK: - APITargetType

public protocol APITargetType: TargetType {}

// MARK: - APIResponse

public struct APIResponse: Sendable {
    
    /// The status code of the response.
    public let statusCode: Int

    /// The response data.
    public let data: Data

    /// The original URLRequest for the response.
    public let request: URLRequest?

    /// The HTTPURLResponse object.
    public let response: HTTPURLResponse?
}

// MARK: - Moya.Response extension for APIResponse

public extension Moya.Response {
    
    var apiResponse: APIResponse {
        
        .init(statusCode: statusCode, data: data, request: request, response: response)
    }
}

// MARK: - APIError

public enum APIError: Swift.Error {
    
    /// Indicates a response failed to map to an image.
    case imageMapping(APIResponse)

    /// Indicates a response failed to map to a JSON structure.
    case jsonMapping(APIResponse)

    /// Indicates a response failed to map to a String.
    case stringMapping(APIResponse)

    /// Indicates a response failed to map to a Decodable object.
    case objectMapping(Swift.Error, APIResponse)

    /// Indicates that Encodable couldn't be encoded into Data
    case encodableMapping(Swift.Error)

    /// Indicates a response failed with an invalid HTTP status code.
    case statusCode(APIResponse)

    /// Indicates a response failed due to an underlying `Error`.
    case underlying(Swift.Error, APIResponse?)

    /// Indicates that an `Endpoint` failed to map to a `URLRequest`.
    case requestMapping(String)

    /// Indicates that an `Endpoint` failed to encode the parameters for the `URLRequest`.
    case parameterEncoding(Swift.Error)
}

// MARK: - MoyaError extension for APIError

public extension MoyaError {
    
    var apiError: APIError {
        switch self {
        case .imageMapping(let response):
            return .imageMapping(response.apiResponse)
        case .jsonMapping(let response):
            return .jsonMapping(response.apiResponse)
        case .stringMapping(let response):
            return .stringMapping(response.apiResponse)
        case .objectMapping(let error, let response):
            return .objectMapping(error, response.apiResponse)
        case .encodableMapping(let error):
            return .encodableMapping(error)
        case .statusCode(let response):
            return .statusCode(response.apiResponse)
        case .underlying(let error, let response):
            return .underlying(error, response?.apiResponse)
        case .requestMapping(let string):
            return .requestMapping(string)
        case .parameterEncoding(let error):
            return .parameterEncoding(error)
        }
    }
}

// MARK: - CustomSession

public class CustomSession: Alamofire.Session, @unchecked Sendable {
    static func create(
        protocolClasses: [AnyClass]? = nil,
        timeoutIntervalForRequest: TimeInterval = 30,
        requestCachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalCacheData,
        interceptors: [APIInterceptor]
    ) -> CustomSession {
        
        let configuration = URLSessionConfiguration.default
        
        configuration.protocolClasses = []
        configuration.timeoutIntervalForRequest = 0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        let interceptor = Interceptor(interceptors: interceptors)
        
        return .init(configuration: configuration, interceptor: interceptor)
    }
}

// MARK: - APIInterceptor

public protocol APIInterceptor: RequestInterceptor {}
