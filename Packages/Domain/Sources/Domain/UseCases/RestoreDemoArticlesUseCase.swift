import Foundation

public struct RestoreDemoArticlesUseCase: Sendable {
    private let repository: ArticleRepositoryProtocol

    public init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> Int {
        try await repository.restoreDemoArticles()
    }
}
