import Core
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class FavoritesViewModel {
    public private(set) var viewState: ViewState<[Article]> = .idle

    private let fetchFavorites: FetchFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    public init(
        fetchFavorites: FetchFavoritesUseCase,
        toggleFavorite: ToggleFavoriteUseCase
    ) {
        self.fetchFavorites = fetchFavorites
        self.toggleFavorite = toggleFavorite
    }

    public func onAppear() async {
        await load()
    }

    public func removeFavorite(_ article: Article) async {
        do {
            _ = try await toggleFavorite.execute(articleId: article.id)
            await load()
        } catch {
            viewState = .error(errorMessage(for: error))
        }
    }

    private func load() async {
        viewState = .loading
        do {
            let favorites = try await fetchFavorites.execute()
            viewState = favorites.isEmpty ? .empty : .loaded(favorites)
        } catch {
            viewState = .error(errorMessage(for: error))
        }
    }

    private func errorMessage(for error: Error) -> String {
        if let domainError = error as? DomainError {
            return domainError.userMessage
        }
        return DomainError.loadFailed.userMessage
    }
}
