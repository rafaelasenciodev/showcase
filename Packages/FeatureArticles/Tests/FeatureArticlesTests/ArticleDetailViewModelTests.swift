import Domain
import FeatureArticles
import SharedTesting
import Testing

@MainActor
@Suite("ArticleDetailViewModel")
struct ArticleDetailViewModelTests {
    @Test("loads article detail")
    func loadDetail() async {
        let repository = MockArticleRepository()
        let favorites = MockFavoriteRepository()
        let viewModel = ArticleDetailViewModel(
            articleId: "swift-concurrency-2024",
            fetchDetail: FetchArticleDetailUseCase(repository: repository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favorites),
            isFavoriteCheck: { id in try await favorites.isFavorite(articleId: id) }
        )
        await viewModel.onAppear()
        if case let .loaded(article) = viewModel.viewState {
            #expect(article.id == "swift-concurrency-2024")
        } else {
            Issue.record("Expected loaded state")
        }
    }
}
