//
//  Composition.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/23
//  

import Data
import Domain

public enum Composition {
    public static func make(
        session: CustomSession
    ) -> APIRequesting { APIRequestClient(session: session) }
}
