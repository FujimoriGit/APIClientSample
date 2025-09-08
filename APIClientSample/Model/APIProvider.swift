//
//  APIProvider.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/30
//

import Composition
import Domain
import Foundation

private enum APIProviderKey: DependencyKey {
    
    static let liveValue = Composition.make(session: .init())
}

extension DependencyValues {
    
    var apiProvider: APIRequesting {
        get { self[APIProviderKey.self] }
        set { self[APIProviderKey.self] = newValue }
    }
}
