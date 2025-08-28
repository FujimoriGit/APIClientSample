import Alamofire

final class CountingInterceptor: RequestInterceptor {
    private(set) var adaptCount = 0
    private(set) var retryCount = 0

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        adaptCount += 1
        var req = urlRequest
        req.addValue("Bearer token", forHTTPHeaderField: "Authorization")
        completion(.success(req))
    }

    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        if retryCount == 0, let afError = error as? AFError {
            switch afError {
            case .sessionTaskFailed(let underlying as URLError)
                where underlying.code == .timedOut || underlying.code == .cannotFindHost || underlying.code == .cannotConnectToHost:
                retryCount += 1
                completion(.retryWithDelay(0.05))
                return
            default: break
            }
        }
        completion(.doNotRetry)
    }
}
