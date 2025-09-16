//
//  APIRequestClient.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/23
//  

import Domain
import Foundation
import Alamofire
@preconcurrency import Moya

package final class APIRequestClient: APIRequesting {

    public let session: CustomSession
    private let provider: MoyaProvider<TargetAdapter>

    public init(session: CustomSession) {
        self.session = session
        self.provider = MoyaProvider<TargetAdapter>(
            session: session
        )
    }
    
    package func request(
        _ target: any Domain.APITargetType,
        callbackQueue: DispatchQueue?,
        completion: @escaping (Result<Domain.APIResponse, Domain.APIError>) -> Void
    ) {
        provider.request(
            TargetAdapter(target),
            callbackQueue: callbackQueue
        ) { result in
            switch result {
            case .success(let response):
                completion(.success(response.apiResponse))
            case .failure(let error):
                completion(.failure(error.apiError))
            }
        }
    }
}

private struct TargetAdapter: Moya.TargetType {
    let target: any Domain.APITargetType

    init(_ target: any Domain.APITargetType) {
        self.target = target
    }

    var baseURL: URL { target.baseURL }
    var path: String { target.path }
    var method: Moya.Method { target.method.moyaMethod }
    var sampleData: Data { target.sampleData }
    var task: Moya.Task { target.task.moyaTask }
    var headers: [String: String]? { target.headers }
    var validationType: Moya.ValidationType { target.validationType.moyaValidationType }
}

private extension Domain.APIHTTPMethod {
    var moyaMethod: Moya.Method {
        switch self {
        case .get: return .get
        case .post: return .post
        case .put: return .put
        case .patch: return .patch
        case .delete: return .delete
        case .options: return .options
        case .head: return .head
        case .trace: return .trace
        case .connect: return .connect
        }
    }
}

private extension Domain.APIValidationType {
    var moyaValidationType: Moya.ValidationType {
        switch self {
        case .none: return .none
        case .successCodes: return .successCodes
        case .custom(let codes): return .customCodes(codes)
        }
    }
}

private extension Domain.APITask {
    var moyaTask: Moya.Task {
        switch self {
        case .requestPlain:
            return .requestPlain
        case .requestData(let data):
            return .requestData(data)
        case .requestParameters(let parameters, let encoding):
            return .requestParameters(parameters: parameters, encoding: encoding.parameterEncoding)
        }
    }
}

private extension Domain.APIParameterEncoding {
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .url: return URLEncoding.default
        case .json: return JSONEncoding.default
        }
    }
}
