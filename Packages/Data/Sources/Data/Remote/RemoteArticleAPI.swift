import Foundation
import Networking

struct RemoteArticleAPI: Sendable {
    private let client: APIClientProtocol
    private let encoder: JSONEncoder

    init(client: APIClientProtocol) {
        self.client = client
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func fetchAll() async throws -> [ArticleDTO] {
        try await client.request(ArticleEndpoints.listArticles, responseType: [ArticleDTO].self)
    }

    func create(_ payload: RemoteArticlePayload) async throws -> ArticleDTO {
        let body = try encode(payload)
        return try await client.request(
            ArticleEndpoints.createArticle(body: body),
            responseType: ArticleDTO.self
        )
    }

    func update(_ payload: RemoteArticlePayload) async throws -> ArticleDTO {
        let body = try encode(payload)
        return try await client.request(
            ArticleEndpoints.updateArticle(id: payload.id, body: body),
            responseType: ArticleDTO.self
        )
    }

    func delete(id: String) async throws {
        do {
            try await client.request(ArticleEndpoints.deleteArticle(id: id))
        } catch NetworkError.notFound {
            // Already removed remotely.
        }
    }

    private func encode<T: Encodable>(_ value: T) throws -> Data {
        do {
            return try encoder.encode(value)
        } catch {
            throw NetworkError.encodingFailed
        }
    }
}
