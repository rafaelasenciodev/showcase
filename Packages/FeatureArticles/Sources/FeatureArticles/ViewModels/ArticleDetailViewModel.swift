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
    private let deleteArticle: DeleteArticleUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let isFavoriteCheck: (String) async throws -> Bool

    public init(
        articleId: String,
        fetchDetail: FetchArticleDetailUseCase,
        deleteArticle: DeleteArticleUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        isFavoriteCheck: @escaping (String) async throws -> Bool
    ) {
        self.articleId = articleId
        self.fetchDetail = fetchDetail
        self.deleteArticle = deleteArticle
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.isFavoriteCheck = isFavoriteCheck
    }

    public var currentArticle: Article? {
        if case let .loaded(article) = viewState {
            return article
        }
        return nil
    }

    public func onAppear() async {
        await load()
    }

    public func applyUpdated(_ article: Article) {
        viewState = .loaded(article)
    }

    public func delete() async throws {
        try await deleteArticle.execute(id: articleId)
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
