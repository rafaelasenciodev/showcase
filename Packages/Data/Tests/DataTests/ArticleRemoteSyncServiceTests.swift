@testable import Data
import Core
import Foundation
import Networking
import SwiftData
import Testing

@MainActor
@Suite("ArticleRemoteSyncService")
struct ArticleRemoteSyncServiceTests {
    @Test("applies remote edits on pull when article has no pending local changes")
    func appliesRemoteEditsDespiteStaleUpdatedAt() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let publishedAt = ISO8601DateFormatter().date(from: "2024-05-01T10:00:00Z")!
        let syncedAt = ISO8601DateFormatter().date(from: "2024-05-02T12:00:00Z")!

        context.insert(
            ArticleModel(
                id: "remote-1",
                title: "Old Title",
                author: "Author",
                publishedAt: publishedAt,
                summary: "Old summary",
                content: "Old content",
                updatedAt: syncedAt,
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
                title: "Updated On Web",
                author: "Author",
                publishedAt: publishedAt,
                summary: "New summary",
                content: "New content",
                updatedAt: publishedAt
            )
        ]

        let service = ArticleRemoteSyncService(
            modelContext: context,
            api: RemoteArticleAPI(client: mockClient)
        )
        try await service.sync()

        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.id == "remote-1" }
        )
        let model = try #require(try context.fetch(descriptor).first)
        #expect(model.title == "Updated On Web")
        #expect(model.summary == "New summary")
        #expect(model.content == "New content")
    }

    @Test("pushes local edits to remote before applying pull merge")
    func pushesLocalEdits() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let publishedAt = ISO8601DateFormatter().date(from: "2024-05-01T10:00:00Z")!
        let remoteUpdatedAt = ISO8601DateFormatter().date(from: "2024-05-02T12:00:00Z")!
        let localUpdatedAt = ISO8601DateFormatter().date(from: "2024-05-03T15:00:00Z")!

        context.insert(
            ArticleModel(
                id: "remote-1",
                title: "Edited In App",
                author: "Author",
                publishedAt: publishedAt,
                summary: "Local summary",
                content: "Local content",
                updatedAt: localUpdatedAt,
                isDemoSeed: false,
                isOnRemote: true,
                needsSyncPush: true
            )
        )
        try context.save()

        let mockClient = MockAPIClient()
        mockClient.articles = [
            ArticleDTO(
                id: "remote-1",
                title: "Stale Remote",
                author: "Author",
                publishedAt: publishedAt,
                summary: "Remote summary",
                content: "Remote content",
                updatedAt: remoteUpdatedAt
            )
        ]

        let service = ArticleRemoteSyncService(
            modelContext: context,
            api: RemoteArticleAPI(client: mockClient)
        )
        try await service.sync()

        let pushed = try #require(mockClient.articles.first { $0.id == "remote-1" })
        #expect(pushed.title == "Edited In App")
        #expect(pushed.content == "Local content")

        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.id == "remote-1" }
        )
        let model = try #require(try context.fetch(descriptor).first)
        #expect(model.needsSyncPush == false)
    }

    @Test("pushes new local article and remaps mockapi-assigned id")
    func pushesNewLocalArticle() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let localID = "11111111-1111-1111-1111-111111111111"

        context.insert(
            ArticleModel(
                id: localID,
                title: "Brand New",
                author: "Author",
                publishedAt: .now,
                summary: "Summary",
                content: "Content",
                updatedAt: .now,
                isDemoSeed: false,
                isOnRemote: false,
                needsSyncPush: true
            )
        )
        try context.save()

        let mockClient = MockAPIClient()
        mockClient.articles = []

        let service = ArticleRemoteSyncService(
            modelContext: context,
            api: RemoteArticleAPI(client: mockClient)
        )
        try await service.sync()

        #expect(mockClient.articles.contains { $0.title == "Brand New" })

        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.title == "Brand New" }
        )
        let model = try #require(try context.fetch(descriptor).first)
        #expect(model.id != localID)
        #expect(model.isOnRemote == true)
        #expect(model.needsSyncPush == false)
    }

    @Test("imports remote article not present locally")
    func importsRemoteArticle() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let mockClient = MockAPIClient()
        mockClient.articles = [
            ArticleDTO(
                id: "remote-1",
                title: "Remote Article",
                author: "Web Author",
                publishedAt: ISO8601DateFormatter().date(from: "2024-05-01T10:00:00Z")!,
                summary: "From web",
                content: "Remote body",
                updatedAt: ISO8601DateFormatter().date(from: "2024-05-01T10:00:00Z")!
            )
        ]

        let service = ArticleRemoteSyncService(
            modelContext: context,
            api: RemoteArticleAPI(client: mockClient)
        )
        try await service.sync()

        let repository = SwiftDataArticleRepository(
            modelContext: context,
            remoteSyncSettings: RemoteSyncSettingsStore(),
            deletionStore: PendingRemoteDeletionStore(),
            seeder: DemoArticleSeeder(),
            syncService: nil
        )
        let articles = try await repository.fetchArticles()
        #expect(articles.contains { $0.id == "remote-1" })
    }

    private func makeContainer() throws -> ModelContainer {
        try ShowcaseModelContainerFactory.make(inMemoryOnly: true)
    }
}
