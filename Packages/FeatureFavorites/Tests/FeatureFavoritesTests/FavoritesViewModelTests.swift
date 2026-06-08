import Domain
import FeatureFavorites
import SharedTesting
import Testing

@MainActor
@Suite("FavoritesViewModel")
struct FavoritesViewModelTests {
    @Test("loads favorites")
    func load() async {
        let favorites = MockFavoriteRepository(favoriteIDs: ["swift-concurrency-2024"])
        let articles = MockArticleRepository()
        let viewModel = FavoritesViewModel(
            fetchFavorites: FetchFavoritesUseCase(
                favoriteRepository: favorites,
                articleRepository: articles
            ),
            toggleFavorite: ToggleFavoriteUseCase(repository: favorites)
        )
        await viewModel.onAppear()
        if case let .loaded(items) = viewModel.viewState {
            #expect(items.count == 1)
        } else {
            Issue.record("Expected loaded favorites")
        }
    }
}
