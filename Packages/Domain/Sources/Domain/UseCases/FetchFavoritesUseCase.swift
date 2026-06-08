import Core
import Foundation

@MainActor
public struct FetchFavoritesUseCase {
    private let favoriteRepository: FavoriteRepositoryProtocol
    private let articleRepository: ArticleRepositoryProtocol
    private let logger: Logger

    public init(
        favoriteRepository: FavoriteRepositoryProtocol,
        articleRepository: ArticleRepositoryProtocol,
        logger: Logger = DefaultLogger()
    ) {
        self.favoriteRepository = favoriteRepository
        self.articleRepository = articleRepository
        self.logger = logger
    }

    public func execute() async throws -> [Article] {
        let favoriteIDs = try await favoriteRepository.fetchFavoriteIDs()
        guard !favoriteIDs.isEmpty else { return [] }

        let articles = try await articleRepository.fetchArticles()
        let articleMap = Dictionary(uniqueKeysWithValues: articles.map { ($0.id, $0) })

        return favoriteIDs.compactMap { id in
            if let article = articleMap[id] {
                return article
            }
            logger.info("Favorite article \(id) not found in catalog")
            return nil
        }
    }
}
