import Foundation
import SwiftData

enum ShowcaseSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(2, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [ArticleModel.self, FavoriteArticleModel.self]
    }
}
