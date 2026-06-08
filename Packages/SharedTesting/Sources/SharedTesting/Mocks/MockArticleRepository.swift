import Core
import Domain
import Foundation

public final class MockArticleRepository: ArticleRepositoryProtocol, @unchecked Sendable {
    public var articles: [Article]
    public var shouldThrow: Error?

    public init(articles: [Article] = ArticleFixtures.samples, shouldThrow: Error? = nil) {
        self.articles = articles
        self.shouldThrow = shouldThrow
    }

    public func fetchArticles() async throws -> [Article] {
        if let shouldThrow { throw shouldThrow }
        return articles
    }

    public func fetchArticle(id: String) async throws -> Article {
        if let shouldThrow { throw shouldThrow }
        guard let article = articles.first(where: { $0.id == id }) else {
            throw DomainError.notFound
        }
        return article
    }

    public func refreshArticles() async throws -> [Article] {
        try await fetchArticles()
    }
}
