import Foundation

public struct FavoriteArticle: Equatable, Sendable {
    public let articleId: String
    public let savedAt: Date

    public init(articleId: String, savedAt: Date = .now) {
        self.articleId = articleId
        self.savedAt = savedAt
    }
}
