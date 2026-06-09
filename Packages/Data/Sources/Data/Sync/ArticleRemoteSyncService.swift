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

    func sync() async throws {
        let remoteArticles = try await api.fetchAll()
        let remoteByID = Dictionary(uniqueKeysWithValues: remoteArticles.map { ($0.id, $0) })

        try await removeLocalArticlesDeletedRemotely(remoteByID: remoteByID)
        try mergeRemoteArticles(remoteByID: remoteByID)
        try await pushPendingChanges()
        try await pushPendingDeletions()
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
        let remoteUpdatedAt = remote.resolvedUpdatedAt

        if local.needsSyncPush {
            if remoteUpdatedAt > local.updatedAt {
                ArticlePersistenceMapper.applyRemote(remote, to: local)
            } else if remoteUpdatedAt == local.updatedAt {
                ArticlePersistenceMapper.applyRemote(remote, to: local)
            }
            return
        }

        if remoteUpdatedAt >= local.updatedAt {
            ArticlePersistenceMapper.applyRemote(remote, to: local)
        }
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
                if remote.id != model.id {
                    model.id = remote.id
                }
                ArticlePersistenceMapper.applyRemote(remote, to: model)
            }
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
