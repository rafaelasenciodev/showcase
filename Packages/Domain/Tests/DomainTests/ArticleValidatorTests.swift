import Core
import Domain
import Foundation
import Testing

@Suite("ArticleValidator")
struct ArticleValidatorTests {
    @Test("accepts valid draft")
    func validDraft() throws {
        let draft = ArticleDraft(
            title: "Valid Title",
            author: "Author",
            summary: "Summary",
            content: "Content body"
        )
        try ArticleValidator.validate(draft)
    }

    @Test("rejects empty title")
    func emptyTitle() {
        let draft = ArticleDraft(title: "   ", author: "Author", summary: "Summary", content: "Content")
        #expect(throws: DomainError.self) {
            try ArticleValidator.validate(draft)
        }
    }

    @Test("rejects short title")
    func shortTitle() {
        let draft = ArticleDraft(title: "Hi", author: "Author", summary: "Summary", content: "Content")
        #expect(throws: DomainError.self) {
            try ArticleValidator.validate(draft)
        }
    }
}

@Suite("CreateArticleUseCase")
struct CreateArticleUseCaseTests {
    @Test("validates before create")
    func validates() async {
        let repository = RecordingArticleRepository()
        let useCase = CreateArticleUseCase(repository: repository)
        let draft = ArticleDraft(title: "AB", author: "Author", summary: "Summary", content: "Content")
        do {
            _ = try await useCase.execute(draft: draft)
            Issue.record("Expected validation failure")
        } catch let error as DomainError {
            if case .validationFailed = error {
                #expect(repository.createCallCount == 0)
            } else {
                Issue.record("Unexpected error: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type")
        }
    }
}

private final class RecordingArticleRepository: ArticleRepositoryProtocol, @unchecked Sendable {
    var createCallCount = 0

    func fetchArticles() async throws -> [Article] { [] }
    func fetchArticle(id: String) async throws -> Article { throw DomainError.notFound }
    func refreshArticles() async throws -> [Article] { [] }
    func syncWithRemote() async throws -> [Article] { [] }
    func createArticle(_ draft: ArticleDraft) async throws -> Article {
        createCallCount += 1
        return Article(
            id: "new",
            title: draft.title,
            author: draft.author,
            publishedAt: .now,
            summary: draft.summary,
            content: draft.content
        )
    }
    func updateArticle(id: String, draft: ArticleDraft) async throws -> Article { throw DomainError.unsupportedOperation }
    func deleteArticle(id: String) async throws {}
    func seedDemoContentIfNeeded() async throws {}
    func restoreDemoArticles() async throws -> Int { 0 }
}
