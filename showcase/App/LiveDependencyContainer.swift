import Core
import Data
import Domain
import FeatureArticlesCore
import FeatureArticlesUI
import FeatureFavoritesCore
import FeatureFavoritesUI
import FeatureSettingsCore
import FeatureSettingsUI
import SwiftData

@MainActor
final class LiveDependencyContainer: DependencyContaining {
    let networkMonitor = NetworkConnectivityMonitor()

    private let articleRepository: ArticleRepositoryProtocol
    private let favoriteRepository: FavoriteRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    private(set) lazy var articlesListViewModel = ArticlesListViewModel(
        fetchArticles: FetchArticlesUseCase(repository: articleRepository),
        searchArticles: SearchArticlesUseCase(),
        refreshArticles: RefreshArticlesUseCase(repository: articleRepository),
        deleteArticle: DeleteArticleUseCase(repository: articleRepository),
        toggleFavorite: ToggleFavoriteUseCase(repository: favoriteRepository),
        fetchFavoriteIDs: { [favoriteRepository] in
            try await favoriteRepository.fetchFavoriteIDs()
        },
        networkMonitor: networkMonitor
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
        updateTheme: UpdateThemeUseCase(repository: settingsRepository),
        updateRemoteSync: UpdateRemoteSyncUseCase(repository: settingsRepository),
        restoreDemoArticles: RestoreDemoArticlesUseCase(repository: articleRepository)
    )

    init(
        dataSourceConfiguration: DataSourceConfiguration = .local,
        modelContext: ModelContext
    ) {
        self.articleRepository = ArticleRepositoryFactory.make(
            configuration: dataSourceConfiguration,
            modelContext: modelContext
        )
        self.favoriteRepository = SwiftDataFavoriteRepository(modelContext: modelContext)
        self.settingsRepository = UserDefaultsSettingsRepository()
    }

    func seedArticlesIfNeeded() async throws {
        try await articleRepository.seedDemoContentIfNeeded()
    }

    func makeArticleEditorViewModel(for article: Article? = nil) -> ArticleEditorViewModel {
        if let article {
            ArticleEditorViewModel(
                mode: .edit(article),
                updateArticle: UpdateArticleUseCase(repository: articleRepository)
            )
        } else {
            ArticleEditorViewModel(
                mode: .create,
                createArticle: CreateArticleUseCase(repository: articleRepository)
            )
        }
    }

    func makeArticleDetailViewModel(articleId: String) -> ArticleDetailViewModel {
        ArticleDetailViewModel(
            articleId: articleId,
            fetchDetail: FetchArticleDetailUseCase(repository: articleRepository),
            deleteArticle: DeleteArticleUseCase(repository: articleRepository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(repository: favoriteRepository),
            isFavoriteCheck: { [favoriteRepository] id in
                try await favoriteRepository.isFavorite(articleId: id)
            }
        )
    }

    func configureSettings(
        onThemeChanged: @escaping (AppTheme) -> Void,
        onDemoArticlesRestored: @escaping () async -> Void
    ) {
        settingsViewModel.onThemeChanged = onThemeChanged
        settingsViewModel.onDemoArticlesRestored = onDemoArticlesRestored
    }
}
