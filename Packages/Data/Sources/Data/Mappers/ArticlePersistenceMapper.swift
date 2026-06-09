import Domain
import Foundation

enum ArticlePersistenceMapper {
    static func toDomain(_ model: ArticleModel) -> Article {
        Article(
            id: model.id,
            title: model.title,
            author: model.author,
            publishedAt: model.publishedAt,
            summary: model.summary,
            content: model.content
        )
    }

    static func apply(_ draft: ArticleDraft, to model: ArticleModel, updatedAt: Date = .now) {
        model.title = draft.title
        model.author = draft.author
        model.summary = draft.summary
        model.content = draft.content
        model.updatedAt = updatedAt
    }

    static func applyRemote(_ dto: ArticleDTO, to model: ArticleModel) {
        model.title = dto.title
        model.author = dto.author
        model.publishedAt = dto.publishedAt
        model.summary = dto.summary
        model.content = dto.content
        model.updatedAt = dto.resolvedUpdatedAt
        model.isOnRemote = true
        model.needsSyncPush = false
    }

    static func makeModel(from draft: ArticleDraft, id: String, publishedAt: Date, isDemoSeed: Bool) -> ArticleModel {
        let now = Date.now
        return ArticleModel(
            id: id,
            title: draft.title,
            author: draft.author,
            publishedAt: publishedAt,
            summary: draft.summary,
            content: draft.content,
            updatedAt: now,
            isDemoSeed: isDemoSeed,
            isOnRemote: false,
            needsSyncPush: !isDemoSeed
        )
    }

    static func makeModel(from dto: ArticleDTO, isDemoSeed: Bool) -> ArticleModel {
        ArticleModel(
            id: dto.id,
            title: dto.title,
            author: dto.author,
            publishedAt: dto.publishedAt,
            summary: dto.summary,
            content: dto.content,
            updatedAt: dto.resolvedUpdatedAt,
            isDemoSeed: isDemoSeed,
            isOnRemote: false,
            needsSyncPush: false
        )
    }

    static func makeUserModel(from dto: ArticleDTO) -> ArticleModel {
        ArticleModel(
            id: dto.id,
            title: dto.title,
            author: dto.author,
            publishedAt: dto.publishedAt,
            summary: dto.summary,
            content: dto.content,
            updatedAt: dto.resolvedUpdatedAt,
            isDemoSeed: false,
            isOnRemote: true,
            needsSyncPush: false
        )
    }
}
