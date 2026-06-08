import Foundation

public enum DomainError: Error, Equatable, Sendable {
    case notFound
    case loadFailed
    case persistenceFailed
    case networkUnavailable
    case decodingFailed

    public var userMessage: String {
        switch self {
        case .notFound:
            "The requested content could not be found."
        case .loadFailed:
            "Unable to load content. Please try again."
        case .persistenceFailed:
            "Unable to save your changes."
        case .networkUnavailable:
            "Network unavailable. Check your connection."
        case .decodingFailed:
            "The content format is invalid."
        }
    }
}
