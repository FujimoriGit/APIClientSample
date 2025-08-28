import Alamofire

func makeTestingSession(interceptor: RequestInterceptor? = nil) -> Session {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    config.timeoutIntervalForRequest = 5
    config.timeoutIntervalForResource = 5
    return Session(configuration: config, interceptor: interceptor)
}
