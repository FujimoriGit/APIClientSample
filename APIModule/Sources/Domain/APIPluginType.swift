//
//  APIPluginType.swift
//  APIModule
//  
//  Created by Daiki Fujimori on 2025/09/15
//  

import Foundation

public protocol APIPluginType: Sendable {

    func process(_ result: Result<APIResponse, APIError>, target: APITargetType) -> Result<APIResponse, APIError>
}

public enum APIHTTPMethod: String, CaseIterable {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case options = "OPTIONS"
    case head    = "HEAD"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public enum APIValidationType {
    case none
    case successCodes
    case custom([Int])
}

public enum APIParameterEncoding {
    case url
    case json
}

public enum APITask {
    case requestPlain
    case requestData(Data)
    case requestParameters([String: Any], encoding: APIParameterEncoding)
    // 必要に応じて追加
}

public protocol APITargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: APIHTTPMethod { get }
    var sampleData: Data { get }
    var task: APITask { get }
    var validationType: APIValidationType { get }
    var headers: [String: String]? { get }
}
