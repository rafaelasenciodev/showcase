import Foundation

@MainActor
public protocol FavoriteRepositoryProtocol {
    func fetchFavoriteIDs() async throws -> [String]
    func isFavorite(articleId: String) async throws -> Bool
    func addFavorite(articleId: String) async throws
    func removeFavorite(articleId: String) async throws
    func toggleFavorite(articleId: String) async throws -> Bool
}
