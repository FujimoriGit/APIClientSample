import Dependencies
import Alamofire

public enum NetworkProviderKey: DependencyKey {
    public static let liveValue: NetworkProviding = {
        let session = Session(configuration: .default)
        return MoyaNetworkProvider(session: session, plugins: [])
    }()
    public static var testValue: NetworkProviding {
        unimplemented(
            "NetworkProviding.testValue is not set",
            placeholder: MoyaNetworkProvider(session: Session(configuration: .default))
        )
    }
}

public extension DependencyValues {
    var network: NetworkProviding {
        get { self[NetworkProviderKey.self] }
        set { self[NetworkProviderKey.self] = newValue }
    }
}
