import Foundation

public struct RefreshArticlesUseCase: Sendable {
    private let repository: ArticleRepositoryProtocol

    public init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Article] {
        let articles = try await repository.refreshArticles()
        return articles.sorted { $0.publishedAt > $1.publishedAt }
    }
}
