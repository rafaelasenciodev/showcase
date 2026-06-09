import Foundation
import SwiftData

@Model
public final class ArticleModel {
    @Attribute(.unique) public var id: String
    public var title: String
    public var author: String
    public var publishedAt: Date
    public var summary: String
    public var content: String
    /// Default supports lightweight migration for stores created before remote sync.
    public var updatedAt: Date = Date(timeIntervalSince1970: 0)
    public var isDemoSeed: Bool = false
    public var isOnRemote: Bool = false
    public var needsSyncPush: Bool = false

    public init(
        id: String,
        title: String,
        author: String,
        publishedAt: Date,
        summary: String,
        content: String,
        updatedAt: Date,
        isDemoSeed: Bool = false,
        isOnRemote: Bool = false,
        needsSyncPush: Bool = false
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.publishedAt = publishedAt
        self.summary = summary
        self.content = content
        self.updatedAt = updatedAt
        self.isDemoSeed = isDemoSeed
        self.isOnRemote = isOnRemote
        self.needsSyncPush = needsSyncPush
    }
}
