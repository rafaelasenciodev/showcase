import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case noConnection
    case timeout
    case notFound
    case serverError(Int)
    case decodingFailed
    case encodingFailed
}
