import Foundation

public protocol ArticleRepositoryProtocol: Sendable {
    func fetchArticles() async throws -> [Article]
    func fetchArticle(id: String) async throws -> Article
    func refreshArticles() async throws -> [Article]
}
