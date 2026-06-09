import Foundation

public struct SyncArticlesUseCase: Sendable {
    private let repository: ArticleRepositoryProtocol

    public init(repository: ArticleRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async throws -> [Article] {
        try await repository.syncWithRemote()
    }
}
