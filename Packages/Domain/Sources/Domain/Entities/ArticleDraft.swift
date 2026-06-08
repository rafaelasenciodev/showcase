import Foundation

public struct ArticleDraft: Equatable, Sendable {
    public let title: String
    public let author: String
    public let summary: String
    public let content: String

    public init(title: String, author: String, summary: String, content: String) {
        self.title = title
        self.author = author
        self.summary = summary
        self.content = content
    }
}
