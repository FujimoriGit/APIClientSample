import Foundation
import Moya

public enum UserAPI {
    case getUser(id: String)
}

extension UserAPI: TargetType {
    public var baseURL: URL { URL(string: "https://api.example.com")! }

    public var path: String {
        switch self {
        case .getUser(let id): return "/users/\(id)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getUser: return .get
        }
    }

    public var task: Task {
        switch self {
        case .getUser: return .requestPlain
        }
    }

    public var headers: [String : String]? { nil }

    public var sampleData: Data { Data() }
}
