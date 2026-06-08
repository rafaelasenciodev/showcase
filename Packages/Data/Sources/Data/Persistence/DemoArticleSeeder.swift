import Core
import Domain
import Foundation
import SwiftData

struct DemoArticleSeeder: Sendable {
    private let dataSource: ArticleDataSource

    init(dataSource: ArticleDataSource = LocalJSONArticleDataSource()) {
        self.dataSource = dataSource
    }

    @MainActor
    func seedIfNeeded(modelContext: ModelContext) async throws {
        let count = try modelContext.fetchCount(FetchDescriptor<ArticleModel>())
        guard count == 0 else { return }
        try await importDemoArticles(into: modelContext)
    }

    @MainActor
    func restoreDemoArticles(modelContext: ModelContext) async throws -> Int {
        try deleteDemoArticles(from: modelContext)
        return try await importDemoArticles(into: modelContext)
    }

    @MainActor
    private func importDemoArticles(into modelContext: ModelContext) async throws -> Int {
        let dtos = try await dataSource.loadArticles()
        for dto in dtos {
            let descriptor = FetchDescriptor<ArticleModel>(
                predicate: #Predicate { $0.id == dto.id }
            )
            let existing = try modelContext.fetch(descriptor)
            if existing.isEmpty {
                modelContext.insert(ArticlePersistenceMapper.makeModel(from: dto, isDemoSeed: true))
            }
        }
        try save(modelContext)
        return dtos.count
    }

    @MainActor
    private func deleteDemoArticles(from modelContext: ModelContext) throws {
        let demoDescriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.isDemoSeed == true }
        )
        let demoArticles = try modelContext.fetch(demoDescriptor)
        for article in demoArticles {
            try deleteFavorites(for: article.id, modelContext: modelContext)
            modelContext.delete(article)
        }
        try save(modelContext)
    }

    @MainActor
    private func deleteFavorites(for articleId: String, modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<FavoriteArticleModel>(
            predicate: #Predicate { $0.articleId == articleId }
        )
        let favorites = try modelContext.fetch(descriptor)
        favorites.forEach { modelContext.delete($0) }
    }

    @MainActor
    private func save(_ modelContext: ModelContext) throws {
        do {
            try modelContext.save()
        } catch {
            throw DomainError.persistenceFailed
        }
    }
}
