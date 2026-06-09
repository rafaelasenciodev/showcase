@testable import Data
import Core
import Domain
import Foundation
import Networking
import SwiftData
import Testing

@MainActor
@Suite("SwiftDataArticleRepository")
struct SwiftDataArticleRepositoryTests {
    @Test("creates and fetches article")
    func createAndFetch() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let repository = makeRepository(context: context)

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
        let repository = makeRepository(context: context)

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

    @Test("pushes local update to remote when remote sync is enabled")
    func eagerPushOnUpdate() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let publishedAt = ISO8601DateFormatter().date(from: "2024-05-01T10:00:00Z")!

        context.insert(
            ArticleModel(
                id: "remote-1",
                title: "Original",
                author: "Author",
                publishedAt: publishedAt,
                summary: "Summary",
                content: "Content",
                updatedAt: publishedAt,
                isDemoSeed: false,
                isOnRemote: true,
                needsSyncPush: false
            )
        )
        try context.save()

        let mockClient = MockAPIClient()
        mockClient.articles = [
            ArticleDTO(
                id: "remote-1",
                title: "Original",
                author: "Author",
                publishedAt: publishedAt,
                summary: "Summary",
                content: "Content",
                updatedAt: publishedAt
            )
        ]

        let syncService = ArticleRemoteSyncService(
            modelContext: context,
            api: RemoteArticleAPI(client: mockClient)
        )
        let repository = makeRepository(context: context, syncService: syncService)

        _ = try await repository.updateArticle(
            id: "remote-1",
            draft: ArticleDraft(
                title: "Updated In App",
                author: "Author",
                summary: "Summary",
                content: "Updated content"
            )
        )

        let pushed = try #require(mockClient.articles.first { $0.id == "remote-1" })
        #expect(pushed.title == "Updated In App")
        #expect(pushed.content == "Updated content")
    }

    private func makeContainer() throws -> ModelContainer {
        try ShowcaseModelContainerFactory.make(inMemoryOnly: true)
    }

    private func makeRepository(
        context: ModelContext,
        syncService: ArticleRemoteSyncService? = nil
    ) -> SwiftDataArticleRepository {
        let settings = RemoteSyncSettingsStore()
        settings.setEnabled(true)
        return SwiftDataArticleRepository(
            modelContext: context,
            remoteSyncSettings: settings,
            deletionStore: PendingRemoteDeletionStore(),
            seeder: DemoArticleSeeder(),
            syncService: syncService
        )
    }
}
