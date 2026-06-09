import Core
import Foundation
import Networking
import SwiftData

@MainActor
final class ArticleRemoteSyncService {
    private let modelContext: ModelContext
    private let api: RemoteArticleAPI
    private let deletionStore: PendingRemoteDeletionStore

    init(
        modelContext: ModelContext,
        api: RemoteArticleAPI,
        deletionStore: PendingRemoteDeletionStore = PendingRemoteDeletionStore()
    ) {
        self.modelContext = modelContext
        self.api = api
        self.deletionStore = deletionStore
    }

    /// Uploads pending local creates/updates/deletes without pulling remote changes.
    func pushLocalChanges() async throws {
        try await pushPendingChanges()
        try await pushLocalDeletions()
    }

    func pushLocalDeletions() async throws {
        try await pushPendingDeletions()
        try save()
    }

    /// Pushes a single article when saved locally. Returns the canonical id (mockapi may reassign on create).
    @discardableResult
    func pushArticle(id: String) async throws -> String {
        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            return id
        }
        guard model.needsSyncPush, !model.isDemoSeed else {
            return id
        }

        let oldID = model.id
        let canonicalID: String
        if model.isOnRemote {
            let remote = try await api.update(RemoteArticlePayload(from: model))
            ArticlePersistenceMapper.applyRemote(remote, to: model)
            canonicalID = remote.id
        } else {
            let remote = try await api.create(RemoteArticlePayload(from: model))
            if remote.id != oldID {
                try applyCreatedRemote(remote, replacing: model)
            } else {
                ArticlePersistenceMapper.applyRemote(remote, to: model)
            }
            canonicalID = remote.id
        }
        try save()
        return canonicalID
    }

    func sync() async throws {
        // Upload local pending changes before merging remote so pull cannot clear needsSyncPush first.
        try await pushLocalChanges()

        let remoteArticles = try await api.fetchAll()
        let remoteByID = Dictionary(uniqueKeysWithValues: remoteArticles.map { ($0.id, $0) })

        try removeLocalArticlesDeletedRemotely(remoteByID: remoteByID)
        try mergeRemoteArticles(remoteByID: remoteByID)
        try save()
    }

    private func removeLocalArticlesDeletedRemotely(remoteByID: [String: ArticleDTO]) throws {
        let descriptor = FetchDescriptor<ArticleModel>()
        let localArticles = try modelContext.fetch(descriptor)

        for model in localArticles where !model.isDemoSeed && model.isOnRemote {
            if remoteByID[model.id] == nil {
                try deleteFavorites(for: model.id)
                modelContext.delete(model)
            }
        }
    }

    private func mergeRemoteArticles(remoteByID: [String: ArticleDTO]) throws {
        let descriptor = FetchDescriptor<ArticleModel>()
        let localArticles = try modelContext.fetch(descriptor)
        let localByID = Dictionary(uniqueKeysWithValues: localArticles.map { ($0.id, $0) })

        for (id, remote) in remoteByID {
            if let local = localByID[id] {
                guard !local.isDemoSeed else { continue }
                try merge(remote: remote, into: local)
            } else {
                modelContext.insert(ArticlePersistenceMapper.makeUserModel(from: remote))
            }
        }
    }

    private func merge(remote: ArticleDTO, into local: ArticleModel) throws {
        guard !local.needsSyncPush else { return }

        // No pending local edits → remote is source of truth (mockapi may keep stale `updatedAt`).
        ArticlePersistenceMapper.applyRemote(remote, to: local)
    }

    private func pushPendingChanges() async throws {
        let descriptor = FetchDescriptor<ArticleModel>(
            predicate: #Predicate { $0.needsSyncPush == true && $0.isDemoSeed == false }
        )
        let pending = try modelContext.fetch(descriptor)

        for model in pending {
            let payload = RemoteArticlePayload(from: model)
            if model.isOnRemote {
                let remote = try await api.update(payload)
                ArticlePersistenceMapper.applyRemote(remote, to: model)
            } else {
                let remote = try await api.create(payload)
                try applyCreatedRemote(remote, replacing: model)
            }
        }
    }

    private func applyCreatedRemote(_ remote: ArticleDTO, replacing model: ArticleModel) throws {
        let oldID = model.id
        if remote.id != oldID {
            try updateFavoriteArticleIDs(from: oldID, to: remote.id)
            modelContext.delete(model)
            modelContext.insert(ArticlePersistenceMapper.makeUserModel(from: remote))
        } else {
            ArticlePersistenceMapper.applyRemote(remote, to: model)
        }
    }

    private func updateFavoriteArticleIDs(from oldID: String, to newID: String) throws {
        let descriptor = FetchDescriptor<FavoriteArticleModel>(
            predicate: #Predicate { $0.articleId == oldID }
        )
        let favorites = try modelContext.fetch(descriptor)
        for favorite in favorites {
            favorite.articleId = newID
        }
    }

    private func pushPendingDeletions() async throws {
        for id in deletionStore.all() {
            try await api.delete(id: id)
            deletionStore.remove(id: id)
        }
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
