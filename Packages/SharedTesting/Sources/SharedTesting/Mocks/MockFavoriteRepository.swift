import Domain
import Foundation

@MainActor
public final class MockFavoriteRepository: FavoriteRepositoryProtocol {
    public private(set) var favoriteIDs: [String]

    public init(favoriteIDs: [String] = []) {
        self.favoriteIDs = favoriteIDs
    }

    public func fetchFavoriteIDs() async throws -> [String] {
        favoriteIDs
    }

    public func isFavorite(articleId: String) async throws -> Bool {
        favoriteIDs.contains(articleId)
    }

    public func addFavorite(articleId: String) async throws {
        guard !favoriteIDs.contains(articleId) else { return }
        favoriteIDs.insert(articleId, at: 0)
    }

    public func removeFavorite(articleId: String) async throws {
        favoriteIDs.removeAll { $0 == articleId }
    }

    public func toggleFavorite(articleId: String) async throws -> Bool {
        if favoriteIDs.contains(articleId) {
            try await removeFavorite(articleId: articleId)
            return false
        } else {
            try await addFavorite(articleId: articleId)
            return true
        }
    }
}
