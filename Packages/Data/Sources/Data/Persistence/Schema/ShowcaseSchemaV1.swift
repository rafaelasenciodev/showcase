import Foundation
import SwiftData

/// Schema V1 — must byte-match the unversioned store that shipped before remote sync.
enum ShowcaseSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [ArticleModel.self, FavoriteArticleModel.self]
    }

    /// Nested legacy model keeps the `ArticleModel` entity name for checksum matching.
    @Model
    final class ArticleModel {
        @Attribute(.unique) var id: String
        var title: String
        var author: String
        var publishedAt: Date
        var summary: String
        var content: String
        var isDemoSeed: Bool

        init(
            id: String,
            title: String,
            author: String,
            publishedAt: Date,
            summary: String,
            content: String,
            isDemoSeed: Bool = false
        ) {
            self.id = id
            self.title = title
            self.author = author
            self.publishedAt = publishedAt
            self.summary = summary
            self.content = content
            self.isDemoSeed = isDemoSeed
        }
    }
}
