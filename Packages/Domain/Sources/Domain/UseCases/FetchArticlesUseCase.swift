import Foundation

public struct FetchArticlesUseCase: Sendable {
    private let repository: ArticleRepositoryProtocol

    public init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Article] {
        let articles = try await repository.fetchArticles()
        return articles.sorted { $0.publishedAt > $1.publishedAt }
    }
}
