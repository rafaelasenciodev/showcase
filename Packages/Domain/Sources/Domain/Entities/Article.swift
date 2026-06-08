import Foundation

public struct Article: Identifiable, Equatable, Sendable, Hashable {
    public let id: String
    public let title: String
    public let author: String
    public let publishedAt: Date
    public let summary: String
    public let content: String

    public init(
        id: String,
        title: String,
        author: String,
        publishedAt: Date,
        summary: String,
        content: String
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.publishedAt = publishedAt
        self.summary = summary
        self.content = content
    }
}
