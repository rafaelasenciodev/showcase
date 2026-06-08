import Core
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class ArticleEditorViewModel {
    public enum Mode: Equatable {
        case create
        case edit(Article)
    }

    public var title = ""
    public var author = ""
    public var summary = ""
    public var content = ""
    public private(set) var validationError: String?
    public private(set) var isSaving = false

    public let mode: Mode

    private let createArticle: CreateArticleUseCase?
    private let updateArticle: UpdateArticleUseCase?

    public init(
        mode: Mode,
        createArticle: CreateArticleUseCase? = nil,
        updateArticle: UpdateArticleUseCase? = nil
    ) {
        self.mode = mode
        self.createArticle = createArticle
        self.updateArticle = updateArticle

        if case let .edit(article) = mode {
            title = article.title
            author = article.author
            summary = article.summary
            content = article.content
        }
    }

    public var navigationTitle: String {
        switch mode {
        case .create: "New Article"
        case .edit: "Edit Article"
        }
    }

    public func save() async -> Article? {
        validationError = nil
        isSaving = true
        defer { isSaving = false }

        let draft = ArticleDraft(title: title, author: author, summary: summary, content: content)

        do {
            switch mode {
            case .create:
                guard let createArticle else { return nil }
                return try await createArticle.execute(draft: draft)
            case let .edit(article):
                guard let updateArticle else { return nil }
                return try await updateArticle.execute(id: article.id, draft: draft)
            }
        } catch let error as DomainError {
            validationError = error.userMessage
            return nil
        } catch {
            validationError = DomainError.loadFailed.userMessage
            return nil
        }
    }
}
