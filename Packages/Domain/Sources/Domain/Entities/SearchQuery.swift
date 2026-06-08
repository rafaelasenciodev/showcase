import Foundation

public struct SearchQuery: Equatable, Sendable {
    public let text: String

    public init(text: String) {
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public var isEmpty: Bool {
        text.isEmpty
    }
}
