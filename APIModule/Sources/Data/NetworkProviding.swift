import Foundation
import Moya
import Alamofire

public protocol NetworkProviding {
    var session: Alamofire.Session { get }
    func request(
        _ target: TargetType,
        callbackQueue: DispatchQueue?,
        progress: ProgressBlock?,
        completion: @escaping Completion
    )
}

public struct MoyaNetworkProvider: NetworkProviding {
    public let session: Alamofire.Session
    private let provider: MoyaProvider<MultiTarget>

    public init(session: Alamofire.Session, plugins: [PluginType] = []) {
        self.session = session
        self.provider = MoyaProvider<MultiTarget>(
            session: session,
            plugins: plugins
        )
    }

    public func request(
        _ target: TargetType,
        callbackQueue: DispatchQueue? = nil,
        progress: ProgressBlock? = nil,
        completion: @escaping Completion
    ) {
        provider.request(
            MultiTarget(target),
            callbackQueue: callbackQueue,
            progress: progress,
            completion: completion
        )
    }
}
