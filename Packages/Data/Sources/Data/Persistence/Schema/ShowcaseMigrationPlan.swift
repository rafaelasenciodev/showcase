import Foundation
import SwiftData

/// Versioned schema migration for SwiftData (V1 local CRUD → V2 remote sync metadata).
public enum ShowcaseMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [ShowcaseSchemaV1.self, ShowcaseSchemaV2.self]
    }

    public static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: ShowcaseSchemaV1.self,
        toVersion: ShowcaseSchemaV2.self,
        willMigrate: { context in
            let descriptor = FetchDescriptor<ShowcaseSchemaV1.ArticleModel>()
            let legacyArticles = try context.fetch(descriptor)

            ArticleMigrationBuffer.pending = legacyArticles.map {
                ArticleMigrationBuffer.Snapshot(
                    id: $0.id,
                    title: $0.title,
                    author: $0.author,
                    publishedAt: $0.publishedAt,
                    summary: $0.summary,
                    content: $0.content,
                    isDemoSeed: $0.isDemoSeed
                )
            }

            for article in legacyArticles {
                context.delete(article)
            }
            try context.save()
        },
        didMigrate: { context in
            for snapshot in ArticleMigrationBuffer.pending {
                let model = ArticleModel(
                    id: snapshot.id,
                    title: snapshot.title,
                    author: snapshot.author,
                    publishedAt: snapshot.publishedAt,
                    summary: snapshot.summary,
                    content: snapshot.content,
                    updatedAt: snapshot.publishedAt,
                    isDemoSeed: snapshot.isDemoSeed,
                    isOnRemote: false,
                    needsSyncPush: false
                )
                context.insert(model)
            }
            ArticleMigrationBuffer.pending = []
            try context.save()
        }
    )
}
