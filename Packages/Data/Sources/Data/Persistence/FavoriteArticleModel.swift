import Foundation
import SwiftData

@Model
public final class FavoriteArticleModel {
    @Attribute(.unique) public var articleId: String
    public var savedAt: Date

    public init(articleId: String, savedAt: Date = .now) {
        self.articleId = articleId
        self.savedAt = savedAt
    }
}
