import Foundation

@MainActor
public struct ToggleFavoriteUseCase {
    private let repository: FavoriteRepositoryProtocol

    public init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(articleId: String) async throws -> Bool {
        try await repository.toggleFavorite(articleId: articleId)
    }
}
