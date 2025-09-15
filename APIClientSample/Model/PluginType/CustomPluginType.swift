//
//  CustomPluginType.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/09/15
//  

import Domain

struct CustomPluginType {}

extension CustomPluginType: APIPluginType {
    func process(_ result: Result<Domain.APIResponse, Domain.APIError>,
                 target: APITargetType) -> Result<Domain.APIResponse, Domain.APIError> {
        
        switch result {
            
        case .success(let response):
            return .success(response)
            
        case .failure(let error):
            switch error {
                
            case .imageMapping, .jsonMapping,
                    .stringMapping, .objectMapping,
                    .encodableMapping, .requestMapping,
                    .parameterEncoding:
                return .failure(error)
                
            case .statusCode(let response):
                return .success(response)
                
            case .underlying(_, let response):
                guard let response else { return .failure(error) }
                return .success(response)
            }
        }
    }
}
