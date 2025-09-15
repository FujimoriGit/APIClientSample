//
//  APIRequesting.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/23
//  

import Foundation

// MARK: - APIRequesting

public protocol APIRequesting: Sendable {

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
