import Core
import Domain
import Foundation
import Networking

public final class RemoteArticleRepository: ArticleRepositoryProtocol, @unchecked Sendable {
    private let dataSource: RemoteArticleDataSource
    private let cache = ArticleCache()

    public init(client: APIClientProtocol) {
        self.dataSource = RemoteArticleDataSource(client: client)
    }

    public func fetchArticles() async throws -> [Article] {
        try await loadIfNeeded()
        return await cache.get()
    }

    public func fetchArticle(id: String) async throws -> Article {
        try await loadIfNeeded()
        let articles = await cache.get()
        guard let article = articles.first(where: { $0.id == id }) else {
            throw DomainError.notFound
        }
        return article
    }

    public func refreshArticles() async throws -> [Article] {
        let dtos = try await dataSource.loadArticles()
        let articles = ArticleMapper.toDomain(dtos)
        await cache.set(articles)
        return articles
    }

    private func loadIfNeeded() async throws {
        if await cache.isEmpty() {
            _ = try await refreshArticles()
        }
    }
}
