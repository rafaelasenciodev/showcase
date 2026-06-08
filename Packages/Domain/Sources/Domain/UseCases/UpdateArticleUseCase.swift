import Foundation

public struct UpdateArticleUseCase: Sendable {
    private let repository: ArticleRepositoryProtocol

    public init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(id: String, draft: ArticleDraft) async throws -> Article {
        try ArticleValidator.validate(draft)
        return try await repository.updateArticle(id: id, draft: ArticleValidator.normalized(draft))
    }
}
