import Core
import Domain
import Foundation
import SwiftData

@MainActor
public final class SwiftDataArticleRepository: ArticleRepositoryProtocol {
    private let modelContext: ModelContext
    private let seeder: DemoArticleSeeder

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.seeder = DemoArticleSeeder()
    }

    public func fetchArticles() async throws -> [Article] {
        let descriptor = FetchDescriptor<ArticleModel>(
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        do {
            let models = try modelContext.fetch(descriptor)
            return models.map(ArticlePersistenceMapper.toDomain)
        } catch {
            throw DomainError.persistenceFailed
        }
    }

    public func fetchArticle(id: String) async throws -> Article {
        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.id == id }
        )
        do {
            guard let model = try modelContext.fetch(descriptor).first else {
                throw DomainError.notFound
            }
            return ArticlePersistenceMapper.toDomain(model)
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.persistenceFailed
        }
    }

    public func refreshArticles() async throws -> [Article] {
        try await fetchArticles()
    }

    public func createArticle(_ draft: ArticleDraft) async throws -> Article {
        let model = ArticlePersistenceMapper.makeModel(
            from: draft,
            id: UUID().uuidString,
            publishedAt: .now,
            isDemoSeed: false
        )
        modelContext.insert(model)
        try save()
        return ArticlePersistenceMapper.toDomain(model)
    }

    public func updateArticle(id: String, draft: ArticleDraft) async throws -> Article {
        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.id == id }
        )
        do {
            guard let model = try modelContext.fetch(descriptor).first else {
                throw DomainError.notFound
            }
            ArticlePersistenceMapper.apply(draft, to: model)
            try save()
            return ArticlePersistenceMapper.toDomain(model)
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.persistenceFailed
        }
    }

    public func deleteArticle(id: String) async throws {
        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.id == id }
        )
        do {
            guard let model = try modelContext.fetch(descriptor).first else {
                throw DomainError.notFound
            }
            try deleteFavorites(for: id)
            modelContext.delete(model)
            try save()
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.persistenceFailed
        }
    }

    public func seedDemoContentIfNeeded() async throws {
        try await seeder.seedIfNeeded(modelContext: modelContext)
    }

    public func restoreDemoArticles() async throws -> Int {
        try await seeder.restoreDemoArticles(modelContext: modelContext)
    }

    private func deleteFavorites(for articleId: String) throws {
        let descriptor = FetchDescriptor<FavoriteArticleModel>(
            predicate: #Predicate { $0.articleId == articleId }
        )
        let favorites = try modelContext.fetch(descriptor)
        favorites.forEach { modelContext.delete($0) }
    }

    private func save() throws {
        do {
            try modelContext.save()
        } catch {
            throw DomainError.persistenceFailed
        }
    }
}
