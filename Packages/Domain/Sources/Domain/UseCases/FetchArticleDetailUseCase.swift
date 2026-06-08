import Core
import Foundation

public struct FetchArticleDetailUseCase: Sendable {
    private let repository: ArticleRepositoryProtocol

    public init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: String) async throws -> Article {
        guard !id.isEmpty else { throw DomainError.notFound }
        return try await repository.fetchArticle(id: id)
    }
}
