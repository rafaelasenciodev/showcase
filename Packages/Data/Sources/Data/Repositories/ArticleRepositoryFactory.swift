import Domain
import Foundation
import Networking
import SwiftData

public enum ArticleRepositoryFactory {
    @MainActor
    public static func make(
        configuration: DataSourceConfiguration,
        modelContext: ModelContext
    ) -> ArticleRepositoryProtocol {
        switch configuration {
        case .local:
            return SwiftDataArticleRepository(modelContext: modelContext)
        case let .remote(baseURL):
            let networkConfig = NetworkConfiguration(baseURL: baseURL)
            let client = URLSessionAPIClient(configuration: networkConfig)
            return RemoteArticleRepository(client: client)
        }
    }
}
