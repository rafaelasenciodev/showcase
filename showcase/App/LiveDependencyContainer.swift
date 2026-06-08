import Core
import Data
import Domain
import FeatureArticles
import FeatureFavorites
import FeatureSettings
import SwiftData

@MainActor
final class LiveDependencyContainer: DependencyContaining {
    private let articleRepository: ArticleRepositoryProtocol
    private let favoriteRepository: FavoriteRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    private(set) lazy var articlesListViewModel = ArticlesListViewModel(
        fetchArticles: FetchArticlesUseCase(repository: articleRepository),
        searchArticles: SearchArticlesUseCase(),
        refreshArticles: RefreshArticlesUseCase(repository: articleRepository),
        toggleFavorite: ToggleFavoriteUseCase(repository: favoriteRepository),
        fetchFavoriteIDs: { [favoriteRepository] in
            try await favoriteRepository.fetchFavoriteIDs()
        }
    )

    private(set) lazy var favoritesViewModel = FavoritesViewModel(
        fetchFavorites: FetchFavoritesUseCase(
            favoriteRepository: favoriteRepository,
            articleRepository: articleRepository
        ),
        toggleFavorite: ToggleFavoriteUseCase(repository: favoriteRepository)
    )

    private(set) lazy var settingsViewModel = SettingsViewModel(
        fetchSettings: FetchSettingsUseCase(repository: settingsRepository),
        updateTheme: UpdateThemeUseCase(repository: settingsRepository)
    )

    init(
        dataSourceConfiguration: DataSourceConfiguration = .local,
        modelContext: ModelContext
    ) {
        self.articleRepository = ArticleRepositoryFactory.make(configuration: dataSourceConfiguration)
        self.favoriteRepository = SwiftDataFavoriteRepository(modelContext: modelContext)
        self.settingsRepository = UserDefaultsSettingsRepository()
    }

    func makeArticleDetailViewModel(articleId: String) -> ArticleDetailViewModel {
        ArticleDetailViewModel(
            articleId: articleId,
            fetchDetail: FetchArticleDetailUseCase(repository: articleRepository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoriteRepository),
            isFavoriteCheck: { [favoriteRepository] id in
                try await favoriteRepository.isFavorite(articleId: id)
            }
        )
    }

    func configureSettings(onThemeChanged: @escaping (AppTheme) -> Void) {
        settingsViewModel.onThemeChanged = onThemeChanged
    }
}
