import Core
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class ArticlesListViewModel {
    public private(set) var viewState: ViewState<[Article]> = .idle
    public private(set) var filteredArticles: [Article] = []
    public var searchText: String = "" {
        didSet { applySearch() }
    }
    public private(set) var favoriteIDs: Set<String> = []

    private let fetchArticles: FetchArticlesUseCase
    private let searchArticles: SearchArticlesUseCase
    private let refreshArticles: RefreshArticlesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase
    private let fetchFavoriteIDs: () async throws -> [String]

    private var allArticles: [Article] = []

    public init(
        fetchArticles: FetchArticlesUseCase,
        searchArticles: SearchArticlesUseCase,
        refreshArticles: RefreshArticlesUseCase,
        toggleFavorite: ToggleFavoriteUseCase,
        fetchFavoriteIDs: @escaping () async throws -> [String]
    ) {
        self.fetchArticles = fetchArticles
        self.searchArticles = searchArticles
        self.refreshArticles = refreshArticles
        self.toggleFavorite = toggleFavorite
        self.fetchFavoriteIDs = fetchFavoriteIDs
    }

    public func onAppear() async {
        await loadArticles()
    }

    public func refresh() async {
        viewState = .loading
        do {
            allArticles = try await refreshArticles.execute()
            try await loadFavoriteIDs()
            applySearch()
            updateViewState()
        } catch {
            if allArticles.isEmpty {
                viewState = .error(errorMessage(for: error))
            } else {
                applySearch()
            }
        }
    }

    public func toggleFavorite(for article: Article) async {
        do {
            _ = try await toggleFavorite.execute(articleId: article.id)
            try await loadFavoriteIDs()
        } catch {
            viewState = .error(errorMessage(for: error))
        }
    }

    public func isFavorite(_ article: Article) -> Bool {
        favoriteIDs.contains(article.id)
    }

    private func loadArticles() async {
        viewState = .loading
        do {
            allArticles = try await fetchArticles.execute()
            try await loadFavoriteIDs()
            applySearch()
            updateViewState()
        } catch {
            viewState = .error(errorMessage(for: error))
        }
    }

    private func loadFavoriteIDs() async throws {
        favoriteIDs = Set(try await fetchFavoriteIDs())
    }

    private func applySearch() {
        let query = SearchQuery(text: searchText)
        filteredArticles = searchArticles.execute(query: query, articles: allArticles)
        updateViewState()
    }

    private func updateViewState() {
        if filteredArticles.isEmpty {
            viewState = searchText.isEmpty ? .empty : .empty
        } else {
            viewState = .loaded(filteredArticles)
        }
    }

    private func errorMessage(for error: Error) -> String {
        if let domainError = error as? DomainError {
            return domainError.userMessage
        }
        return DomainError.loadFailed.userMessage
    }
}
