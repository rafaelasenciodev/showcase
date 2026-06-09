import Foundation
import SwiftData

public enum ShowcaseModelContainerFactory {
    public static func make(inMemoryOnly: Bool = false, storeURL: URL? = nil) throws -> ModelContainer {
        let configuration = makeConfiguration(inMemoryOnly: inMemoryOnly, storeURL: storeURL)

        do {
            return try makeMigratedContainer(configuration: configuration)
        } catch where isUnknownModelVersionError(error) && !inMemoryOnly {
            // Stores created before VersionedSchema have no stamped version; opening with V1
            // aligns the on-disk schema so staged migration can run (Apple DTS + community pattern).
            try stampUnversionedStore(configuration: configuration)
            return try makeMigratedContainer(configuration: configuration)
        }
    }

    private static func makeConfiguration(inMemoryOnly: Bool, storeURL: URL?) -> ModelConfiguration {
        if let storeURL {
            ModelConfiguration(url: storeURL)
        } else {
            ModelConfiguration(isStoredInMemoryOnly: inMemoryOnly)
        }
    }

    private static func makeMigratedContainer(configuration: ModelConfiguration) throws -> ModelContainer {
        try ModelContainer(
            for: ArticleModel.self, FavoriteArticleModel.self,
            migrationPlan: ShowcaseMigrationPlan.self,
            configurations: configuration
        )
    }

    private static func stampUnversionedStore(configuration: ModelConfiguration) throws {
        _ = try ModelContainer(
            for: Schema(versionedSchema: ShowcaseSchemaV1.self),
            configurations: configuration
        )
    }

    private static func isUnknownModelVersionError(_ error: Error) -> Bool {
        var nsError = error as NSError
        while true {
            if nsError.domain == NSCocoaErrorDomain, nsError.code == 134504 {
                return true
            }
            guard let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? NSError else {
                return false
            }
            nsError = underlying
        }
    }
}
