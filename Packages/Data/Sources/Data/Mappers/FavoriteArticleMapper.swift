import Domain
import Foundation

enum FavoriteArticleMapper {
    static func toDomain(_ model: FavoriteArticleModel) -> FavoriteArticle {
        FavoriteArticle(articleId: model.articleId, savedAt: model.savedAt)
    }
}
