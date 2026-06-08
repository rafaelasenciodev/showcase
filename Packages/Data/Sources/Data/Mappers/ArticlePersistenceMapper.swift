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

    static func apply(_ draft: ArticleDraft, to model: ArticleModel) {
        model.title = draft.title
        model.author = draft.author
        model.summary = draft.summary
        model.content = draft.content
    }

    static func makeModel(from draft: ArticleDraft, id: String, publishedAt: Date, isDemoSeed: Bool) -> ArticleModel {
        ArticleModel(
            id: id,
            title: draft.title,
            author: draft.author,
            publishedAt: publishedAt,
            summary: draft.summary,
            content: draft.content,
            isDemoSeed: isDemoSeed
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
            isDemoSeed: isDemoSeed
        )
    }
}
