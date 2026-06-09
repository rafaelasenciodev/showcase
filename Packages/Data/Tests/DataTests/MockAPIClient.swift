@testable import Data
import Foundation
import Networking

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var articles: [ArticleDTO] = []

    func request<T>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T where T: Decodable, T: Sendable {
        if endpoint.method == .get, T.self == [ArticleDTO].self {
            return articles as! T
        }
        if endpoint.method == .post, T.self == ArticleDTO.self, let body = endpoint.body {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let payload = try decoder.decode(RemoteArticlePayload.self, from: body)
            let assignedID = "mock-\(articles.count + 1)"
            let dto = ArticleDTO(
                id: assignedID,
                title: payload.title,
                author: payload.author,
                publishedAt: payload.publishedAt,
                summary: payload.summary,
                content: payload.content,
                updatedAt: payload.updatedAt
            )
            articles.append(dto)
            return dto as! T
        }
        if endpoint.method == .put, T.self == ArticleDTO.self, let body = endpoint.body {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let payload = try decoder.decode(RemoteArticlePayload.self, from: body)
            let dto = ArticleDTO(
                id: payload.id,
                title: payload.title,
                author: payload.author,
                publishedAt: payload.publishedAt,
                summary: payload.summary,
                content: payload.content,
                updatedAt: payload.updatedAt
            )
            if let index = articles.firstIndex(where: { $0.id == dto.id }) {
                articles[index] = dto
            }
            return dto as! T
        }
        throw NetworkError.serverError(500)
    }

    func request(_ endpoint: Endpoint) async throws {}
}
