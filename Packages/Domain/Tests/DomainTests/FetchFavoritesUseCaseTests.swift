import Domain
import SharedTesting
import Testing

@MainActor
@Suite("FetchFavoritesUseCase")
struct FetchFavoritesUseCaseTests {
    @Test("returns favorited articles")
    func fetch() async throws {
        let favorites = MockFavoriteRepository(favoriteIDs: ["swift-concurrency-2024"])
        let articles = MockArticleRepository()
        let useCase = FetchFavoritesUseCase(
            favoriteRepository: favorites,
            articleRepository: articles
        )
        let result = try await useCase.execute()
        #expect(result.count == 1)
    }
}
