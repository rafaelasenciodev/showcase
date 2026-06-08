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

    public func createArticle(_ draft: ArticleDraft) async throws -> Article {
        if let shouldThrow { throw shouldThrow }
        let article = Article(
            id: UUID().uuidString,
            title: draft.title,
            author: draft.author,
            publishedAt: .now,
            summary: draft.summary,
            content: draft.content
        )
        articles.append(article)
        return article
    }

    public func updateArticle(id: String, draft: ArticleDraft) async throws -> Article {
        if let shouldThrow { throw shouldThrow }
        guard let index = articles.firstIndex(where: { $0.id == id }) else {
            throw DomainError.notFound
        }
        let existing = articles[index]
        let updated = Article(
            id: existing.id,
            title: draft.title,
            author: draft.author,
            publishedAt: existing.publishedAt,
            summary: draft.summary,
            content: draft.content
        )
        articles[index] = updated
        return updated
    }

    public func deleteArticle(id: String) async throws {
        if let shouldThrow { throw shouldThrow }
        guard let index = articles.firstIndex(where: { $0.id == id }) else {
            throw DomainError.notFound
        }
        articles.remove(at: index)
    }

    public func seedDemoContentIfNeeded() async throws {}

    public func restoreDemoArticles() async throws -> Int {
        if let shouldThrow { throw shouldThrow }
        return articles.count
    }
}
