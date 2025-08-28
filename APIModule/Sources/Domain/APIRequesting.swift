//
//  APIRequesting.swift
//  APIClientSample
//  
//  Created by Daiki Fujimori on 2025/08/23
//  
import Foundation

public protocol APIRequesting: Sendable {
    func fetchUser(id: String, completion: @escaping (Result<Data, Error>) -> Void)
}

public protocol Endpoint {}
