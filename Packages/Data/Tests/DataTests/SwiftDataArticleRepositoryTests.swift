@testable import Data
import Core
import Domain
import Foundation
import SwiftData
import Testing

@MainActor
@Suite("SwiftDataArticleRepository")
struct SwiftDataArticleRepositoryTests {
    @Test("creates and fetches article")
    func createAndFetch() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let repository = SwiftDataArticleRepository(modelContext: context)

        let draft = ArticleDraft(
            title: "New Article",
            author: "Author",
            summary: "Summary",
            content: "Full content"
        )
        let created = try await repository.createArticle(draft)
        let fetched = try await repository.fetchArticle(id: created.id)

        #expect(fetched.title == "New Article")
        #expect(fetched.author == "Author")
    }

    @Test("deletes article")
    func deleteArticle() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let repository = SwiftDataArticleRepository(modelContext: context)

        let created = try await repository.createArticle(
            ArticleDraft(title: "To Delete", author: "Author", summary: "Summary", content: "Content")
        )
        try await repository.deleteArticle(id: created.id)

        do {
            _ = try await repository.fetchArticle(id: created.id)
            Issue.record("Expected not found")
        } catch let error as DomainError {
            #expect(error == .notFound)
        }
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([ArticleModel.self, FavoriteArticleModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
