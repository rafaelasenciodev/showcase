import Core
import Domain
import Foundation
import Networking
import SwiftData

@MainActor
public final class SwiftDataArticleRepository: ArticleRepositoryProtocol {
    private let modelContext: ModelContext
    private let seeder: DemoArticleSeeder
    private let remoteSyncSettings: RemoteSyncSettingsStore
    private let deletionStore: PendingRemoteDeletionStore
    private let syncService: ArticleRemoteSyncService?

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.remoteSyncSettings = RemoteSyncSettingsStore()
        self.deletionStore = PendingRemoteDeletionStore()
        self.seeder = DemoArticleSeeder()

        let configuration = NetworkConfiguration(baseURL: RemoteAPIConfiguration.baseURL)
        let client = URLSessionAPIClient(configuration: configuration)
        let api = RemoteArticleAPI(client: client)
        self.syncService = ArticleRemoteSyncService(
            modelContext: modelContext,
            api: api,
            deletionStore: deletionStore
        )
    }

    init(
        modelContext: ModelContext,
        remoteSyncSettings: RemoteSyncSettingsStore,
        deletionStore: PendingRemoteDeletionStore,
        seeder: DemoArticleSeeder,
        syncService: ArticleRemoteSyncService?
    ) {
        self.modelContext = modelContext
        self.remoteSyncSettings = remoteSyncSettings
        self.deletionStore = deletionStore
        self.seeder = seeder
        self.syncService = syncService
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
        if remoteSyncSettings.isEnabled {
            try await syncWithRemote()
        }
        return try await fetchArticles()
    }

    public func syncWithRemote() async throws -> [Article] {
        guard let syncService else { throw DomainError.loadFailed }
        do {
            try await syncService.sync()
            return try await fetchArticles()
        } catch let error as DomainError {
            throw error
        } catch let error as NetworkError {
            throw map(error)
        } catch {
            throw DomainError.networkUnavailable
        }
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
            if !model.isDemoSeed {
                model.needsSyncPush = true
            }
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
            if !model.isDemoSeed && model.isOnRemote {
                deletionStore.add(id: id)
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

    private func map(_ error: NetworkError) -> DomainError {
        switch error {
        case .notFound:
            .notFound
        case .noConnection, .timeout:
            .networkUnavailable
        case .decodingFailed, .encodingFailed:
            .decodingFailed
        default:
            .loadFailed
        }
    }
}
