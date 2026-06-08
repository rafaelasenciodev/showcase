import Foundation

public struct CreateArticleUseCase: Sendable {
    private let repository: ArticleRepositoryProtocol

    public init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(draft: ArticleDraft) async throws -> Article {
        try ArticleValidator.validate(draft)
        return try await repository.createArticle(ArticleValidator.normalized(draft))
    }
}
