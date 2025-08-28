import Foundation

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest, Int) throws -> (HTTPURLResponse, Data))?

    private static var attemptCounts: [URL: Int] = [:]
    private static let lock = NSLock()

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        MockURLProtocol.lock.lock()
        let attempt = (MockURLProtocol.attemptCounts[url] ?? 0) + 1
        MockURLProtocol.attemptCounts[url] = attempt
        MockURLProtocol.lock.unlock()

        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: -1))
            return
        }

        do {
            let (response, data) = try handler(request, attempt)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func reset() {
        lock.lock()
        attemptCounts.removeAll()
        lock.unlock()
        requestHandler = nil
    }
}
