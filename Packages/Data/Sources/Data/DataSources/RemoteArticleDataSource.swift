import Core
import Foundation
import Networking

struct RemoteArticleDataSource: ArticleDataSource {
    private let client: APIClientProtocol

    init(client: APIClientProtocol) {
        self.client = client
    }

    func loadArticles() async throws -> [ArticleDTO] {
        do {
            let response = try await client.request(
                ArticleEndpoints.listArticles,
                responseType: ArticlesResponseDTO.self
            )
            return response.articles
        } catch let error as NetworkError {
            throw map(error)
        } catch {
            throw DomainError.loadFailed
        }
    }

    private func map(_ error: NetworkError) -> DomainError {
        switch error {
        case .notFound:
            .notFound
        case .noConnection, .timeout:
            .networkUnavailable
        case .decodingFailed:
            .decodingFailed
        default:
            .loadFailed
        }
    }
}
