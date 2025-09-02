//
//  APIRequestClient.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/23
//  

import Domain
import Foundation
@preconcurrency import Moya

package final class APIRequestClient: APIRequesting {
    
    public let session: Domain.CustomSession
    private let provider: MoyaProvider<MultiTarget>
    
    public init(session: Domain.CustomSession) {
        self.session = session
        self.provider = MoyaProvider<MultiTarget>(
            session: session,
        )
    }
    
    package func request(
        _ target: any Domain.APITargetType,
        callbackQueue: DispatchQueue?,
        completion: @escaping (Result<Domain.APIResponse, Domain.APIError>
        ) -> Void) {
        
        provider.request(
            MultiTarget(target),
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
