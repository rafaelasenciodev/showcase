import Foundation
import SwiftData

public enum ArticleMetadataBackfill {
    private static let migrationEpoch = Date(timeIntervalSince1970: 0)

    @MainActor
    public static func applyIfNeeded(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<ArticleModel>()
        let models = try modelContext.fetch(descriptor)
        var didChange = false

        for model in models {
            if model.updatedAt == migrationEpoch {
                model.updatedAt = model.publishedAt
                didChange = true
            }
        }

        if didChange {
            try modelContext.save()
        }
    }
}
