import Domain
import Foundation

enum ArticleMapper {
    static func toDomain(_ dto: ArticleDTO) -> Article {
        Article(
            id: dto.id,
            title: dto.title,
            author: dto.author,
            publishedAt: dto.publishedAt,
            summary: dto.summary,
            content: dto.content
        )
    }

    static func toDomain(_ dtos: [ArticleDTO]) -> [Article] {
        dtos.map(toDomain)
    }
}
