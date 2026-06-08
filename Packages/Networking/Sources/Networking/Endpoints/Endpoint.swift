import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
}

public struct Endpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let headers: [String: String]
    public let queryItems: [URLQueryItem]?

    public init(
        path: String,
        method: HTTPMethod,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem]? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
    }
}
