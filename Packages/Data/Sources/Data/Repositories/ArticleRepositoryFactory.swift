import Domain
import Foundation
import Networking

public enum ArticleRepositoryFactory {
    public static func make(configuration: DataSourceConfiguration) -> ArticleRepositoryProtocol {
        switch configuration {
        case .local:
            return LocalArticleRepository()
        case let .remote(baseURL):
            let networkConfig = NetworkConfiguration(baseURL: baseURL)
            let client = URLSessionAPIClient(configuration: networkConfig)
            return RemoteArticleRepository(client: client)
        }
    }
}
