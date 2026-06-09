@testable import Data
import Foundation
import SwiftData
import Testing

@MainActor
@Suite("ShowcaseMigrationPlan")
struct ShowcaseMigrationPlanTests {
    @Test("creates versioned model container for in-memory store")
    func inMemoryContainer() throws {
        let container = try ShowcaseModelContainerFactory.make(inMemoryOnly: true)
        #expect(container.schema.entities.count >= 2)
    }

    @Test("migrates unversioned on-disk store to sync-enabled schema")
    func unversionedStoreMigration() throws {
        let storeURL = FileManager.default.temporaryDirectory
            .appending(path: "showcase-migration-\(UUID().uuidString).store")
        defer { try? FileManager.default.removeItem(at: storeURL) }

        let legacyConfiguration = ModelConfiguration(url: storeURL)
        let legacyContainer = try ModelContainer(
            for: ShowcaseSchemaV1.ArticleModel.self, FavoriteArticleModel.self,
            configurations: legacyConfiguration
        )
        let legacyContext = ModelContext(legacyContainer)
        legacyContext.insert(
            ShowcaseSchemaV1.ArticleModel(
                id: "legacy-1",
                title: "Legacy",
                author: "Author",
                publishedAt: Date(timeIntervalSince1970: 1_700_000_000),
                summary: "Summary",
                content: "Content",
                isDemoSeed: true
            )
        )
        try legacyContext.save()

        let migratedContainer = try ShowcaseModelContainerFactory.make(storeURL: storeURL)
        let migratedContext = ModelContext(migratedContainer)
        let articles = try migratedContext.fetch(FetchDescriptor<ArticleModel>())

        #expect(articles.count == 1)
        #expect(articles[0].id == "legacy-1")
        #expect(articles[0].updatedAt == articles[0].publishedAt)
        #expect(articles[0].isOnRemote == false)
        #expect(articles[0].needsSyncPush == false)
    }
}
