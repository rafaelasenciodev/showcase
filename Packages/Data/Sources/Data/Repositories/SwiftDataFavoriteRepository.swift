import Core
import Domain
import Foundation
import SwiftData

@MainActor
public final class SwiftDataFavoriteRepository: FavoriteRepositoryProtocol {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func fetchFavoriteIDs() async throws -> [String] {
        let descriptor = FetchDescriptor<FavoriteArticleModel>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        do {
            let models = try modelContext.fetch(descriptor)
            return models.map(\.articleId)
        } catch {
            throw DomainError.persistenceFailed
        }
    }

    public func isFavorite(articleId: String) async throws -> Bool {
        let descriptor = FetchDescriptor<FavoriteArticleModel>(
            predicate: #Predicate { $0.articleId == articleId }
        )
        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            throw DomainError.persistenceFailed
        }
    }

    public func addFavorite(articleId: String) async throws {
        guard try await !isFavorite(articleId: articleId) else { return }
        modelContext.insert(FavoriteArticleModel(articleId: articleId))
        try save()
    }

    public func removeFavorite(articleId: String) async throws {
        let descriptor = FetchDescriptor<FavoriteArticleModel>(
            predicate: #Predicate { $0.articleId == articleId }
        )
        do {
            let models = try modelContext.fetch(descriptor)
            models.forEach { modelContext.delete($0) }
            try save()
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.persistenceFailed
        }
    }

    public func toggleFavorite(articleId: String) async throws -> Bool {
        if try await isFavorite(articleId: articleId) {
            try await removeFavorite(articleId: articleId)
            return false
        } else {
            try await addFavorite(articleId: articleId)
            return true
        }
    }

    private func save() throws {
        do {
            try modelContext.save()
        } catch {
            throw DomainError.persistenceFailed
        }
    }
}
