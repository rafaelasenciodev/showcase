import Domain
import FeatureArticles
import SharedTesting
import Testing

@MainActor
@Suite("ArticlesListViewModel")
struct ArticlesListViewModelTests {
    @Test("loads articles on appear")
    func onAppear() async {
        let repository = MockArticleRepository()
        let favorites = MockFavoriteRepository()
        let viewModel = ArticlesListViewModel(
            fetchArticles: FetchArticlesUseCase(repository: repository),
            searchArticles: SearchArticlesUseCase(),
            refreshArticles: RefreshArticlesUseCase(repository: repository),
            toggleFavorite: ToggleFavoriteUseCase(repository: favorites),
            fetchFavoriteIDs: { try await favorites.fetchFavoriteIDs() }
        )
        await viewModel.onAppear()
        if case let .loaded(articles) = viewModel.viewState {
            #expect(!articles.isEmpty)
        } else {
            Issue.record("Expected loaded state")
        }
    }
}
