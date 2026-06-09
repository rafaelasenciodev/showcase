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
    public var updatedAt: Date
    public var isDemoSeed: Bool
    public var isOnRemote: Bool
    public var needsSyncPush: Bool

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
