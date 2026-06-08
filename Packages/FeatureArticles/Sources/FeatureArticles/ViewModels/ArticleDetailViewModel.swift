import Core
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class ArticleDetailViewModel {
    public private(set) var viewState: ViewState<Article> = .loading
    public private(set) var isFavorite = false

    private let articleId: String
    private let fetchDetail: FetchArticleDetailUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let isFavoriteCheck: (String) async throws -> Bool

    public init(
        articleId: String,
        fetchDetail: FetchArticleDetailUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        isFavoriteCheck: @escaping (String) async throws -> Bool
    ) {
        self.articleId = articleId
        self.fetchDetail = fetchDetail
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.isFavoriteCheck = isFavoriteCheck
    }

    public func onAppear() async {
        await load()
    }

    public func toggleFavorite() async {
        do {
            isFavorite = try await toggleFavoriteUseCase.execute(articleId: articleId)
        } catch {
            viewState = .error(errorMessage(for: error))
        }
    }

    private func load() async {
        viewState = .loading
        do {
            let article = try await fetchDetail.execute(id: articleId)
            isFavorite = try await isFavoriteCheck(articleId)
            viewState = .loaded(article)
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
