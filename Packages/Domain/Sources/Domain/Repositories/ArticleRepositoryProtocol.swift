import Foundation

public protocol ArticleRepositoryProtocol: Sendable {
    func fetchArticles() async throws -> [Article]
    func fetchArticle(id: String) async throws -> Article
    func refreshArticles() async throws -> [Article]
    func createArticle(_ draft: ArticleDraft) async throws -> Article
    func updateArticle(id: String, draft: ArticleDraft) async throws -> Article
    func deleteArticle(id: String) async throws
    func seedDemoContentIfNeeded() async throws
    func restoreDemoArticles() async throws -> Int
}
