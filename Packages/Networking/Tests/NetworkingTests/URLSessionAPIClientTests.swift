import Foundation
import Networking
import Testing

@Suite("URLSessionAPIClient")
struct URLSessionAPIClientTests {
    @Test("decodes successful response")
    func successResponse() async throws {
        let config = NetworkConfiguration(baseURL: URL(string: "https://example.com")!)
        let url = URL(string: "https://example.com/articles")!
        let data = """
        {"articles":[{"id":"a1","title":"T","author":"A","publishedAt":"2024-01-01T00:00:00Z","summary":"S","content":"C"}]}
        """.data(using: .utf8)!
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        let session = URLSession(configuration: MockURLProtocol.sessionConfiguration())
        let client = URLSessionAPIClient(configuration: config, session: session)
        struct Response: Decodable { let articles: [[String: String]] }
        let result = try await client.request(ArticleEndpoints.listArticles, responseType: Response.self)
        #expect(result.articles.count == 1)
    }
}

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func sessionConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return config
    }
}
