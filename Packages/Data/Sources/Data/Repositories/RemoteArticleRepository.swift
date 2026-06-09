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

    public func syncWithRemote() async throws -> [Article] {
        try await refreshArticles()
    }

    public func createArticle(_ draft: ArticleDraft) async throws -> Article {
        throw DomainError.unsupportedOperation
    }

    public func updateArticle(id: String, draft: ArticleDraft) async throws -> Article {
        throw DomainError.unsupportedOperation
    }

    public func deleteArticle(id: String) async throws {
        throw DomainError.unsupportedOperation
    }

    public func seedDemoContentIfNeeded() async throws {}

    public func restoreDemoArticles() async throws -> Int {
        throw DomainError.unsupportedOperation
    }

    private func loadIfNeeded() async throws {
        if await cache.isEmpty() {
            _ = try await refreshArticles()
        }
    }
}
