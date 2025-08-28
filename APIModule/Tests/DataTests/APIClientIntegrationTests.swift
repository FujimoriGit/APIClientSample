import Testing
import Foundation
import Dependencies
import Alamofire
import Moya

@testable import Data

struct APIClientIntegrationTests {

    @Test(arguments: [()]) func setUpEach(_: Void) {
        MockURLProtocol.reset()
    }

    @Test
    func pipeline_through_interceptor_and_plugin() async throws {
        let tokenPlugin = AccessTokenPlugin { _ in "token" }
        let interceptor = CountingInterceptor()

        MockURLProtocol.requestHandler = { request, _ in
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer token")
            let data = #"{"id":"123","name":"Alice"}"#.data(using: .utf8)!
            let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil,
                                       headerFields: ["Content-Type":"application/json"])!
            return (resp, data)
        }

        let session = makeTestingSession(interceptor: interceptor)
        let provider = MoyaNetworkProvider(session: session, plugins: [tokenPlugin])

        let client = withDependencies { $0.network = provider } operation: { APIClient() }

        let result = await withCheckedContinuation { cont in
            client.fetchUser(id: "123") { cont.resume(returning: $0) }
        }

        switch result {
        case .success(let data):
            #expect(!data.isEmpty)
            #expect(interceptor.adaptCount >= 1)
        case .failure(let error):
            Issue.record("unexpected error: \(error)")
        }
    }

    @Test
    func parameterized_status_codes() async throws {
        struct Case { let status: Int; let shouldSucceed: Bool }
        let cases: [Case] = [
            .init(status: 200, shouldSucceed: true),
            .init(status: 201, shouldSucceed: true),
            .init(status: 204, shouldSucceed: true),
            .init(status: 400, shouldSucceed: false),
            .init(status: 401, shouldSucceed: false),
            .init(status: 403, shouldSucceed: false),
            .init(status: 404, shouldSucceed: false),
            .init(status: 429, shouldSucceed: false),
            .init(status: 500, shouldSucceed: false),
            .init(status: 502, shouldSucceed: false),
            .init(status: 503, shouldSucceed: false)
        ]

        for c in cases {
            MockURLProtocol.reset()
            MockURLProtocol.requestHandler = { request, _ in
                let body = c.shouldSucceed
                    ? #"{"ok":true}"#.data(using: .utf8)!
                    : #"{"error":"ng"}"#.data(using: .utf8)!
                let resp = HTTPURLResponse(url: request.url!, statusCode: c.status, httpVersion: nil, headerFields: nil)!
                return (resp, body)
            }

            let provider = MoyaNetworkProvider(session: makeTestingSession())
            let client = withDependencies { $0.network = provider } operation: { APIClient() }

            let result = await withCheckedContinuation { cont in
                client.fetchUser(id: "x") { cont.resume(returning: $0) }
            }

            switch (result, c.shouldSucceed) {
            case (.success, true): break
            case (.failure(let err), false):
                if case let MoyaError.statusCode(res) = err {
                    #expect(res.statusCode == c.status)
                } else {
                    Issue.record("expected statusCode error for \(c.status), got \(err)")
                }
            default:
                Issue.record("mismatch for status \(c.status)")
            }
        }
    }

    @Test
    func network_error_then_retry_success() async throws {
        let interceptor = CountingInterceptor()

        MockURLProtocol.requestHandler = { request, attempt in
            if attempt == 1 {
                throw AFError.sessionTaskFailed(error: URLError(.timedOut))
            } else {
                let data = #"{"id":"999","name":"Bob"}"#.data(using: .utf8)!
                let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (resp, data)
            }
        }

        let provider = MoyaNetworkProvider(session: makeTestingSession(interceptor: interceptor))
        let client = withDependencies { $0.network = provider } operation: { APIClient() }

        let result = await withCheckedContinuation { cont in
            client.fetchUser(id: "999") { cont.resume(returning: $0) }
        }

        switch result {
        case .success(let data):
            #expect(!data.isEmpty)
            #expect(interceptor.retryCount == 1)
        case .failure(let error):
            Issue.record("unexpected error: \(error)")
        }
    }

    @Test
    func network_error_then_retry_exhausted() async throws {
        let interceptor = CountingInterceptor()

        MockURLProtocol.requestHandler = { _, _ in
            throw AFError.sessionTaskFailed(error: URLError(.timedOut))
        }

        let provider = MoyaNetworkProvider(session: makeTestingSession(interceptor: interceptor))
        let client = withDependencies { $0.network = provider } operation: { APIClient() }

        let result = await withCheckedContinuation { cont in
            client.fetchUser(id: "dead") { cont.resume(returning: $0) }
        }

        switch result {
        case .success:
            Issue.record("should have failed")
        case .failure:
            #expect(interceptor.retryCount == 1)
        }
    }
}
