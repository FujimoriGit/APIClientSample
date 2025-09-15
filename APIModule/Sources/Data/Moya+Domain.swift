//
//  Moya+Domain.swift
//  APIModule
//
//  Created by Daiki Fujimori on 2025/09/15
//

import Foundation
import Moya
import Domain

extension Moya.Response {
    var apiResponse: APIResponse {
        .init(statusCode: statusCode, data: data, request: request, response: response)
    }
}

extension MoyaError {
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
