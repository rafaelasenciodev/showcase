import Foundation

public struct NetworkConfiguration: Sendable {
    public let baseURL: URL
    public let timeout: TimeInterval

    public init(baseURL: URL, timeout: TimeInterval = 30) {
        self.baseURL = baseURL
        self.timeout = timeout
    }
}

public protocol APIClientProtocol: Sendable {
    func request<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        responseType: T.Type
    ) async throws -> T

    func request(_ endpoint: Endpoint) async throws
}
