import Foundation
import Dependencies
import Domain
import Moya

@MainActor
public final class APIClient: @preconcurrency APIRequesting {
    @Dependency(\.network) private var network

    public init() {}

    public func fetchUser(id: String, completion: @escaping (Result<Data, Error>) -> Void) {
        network.request(UserAPI.getUser(id: id), callbackQueue: .main, progress: nil) { result in
            switch result {
            case .success(let response):
                completion(.success(response.data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
