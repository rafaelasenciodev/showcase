@testable import Data
import Core
import Foundation
import Networking
import SwiftData
import Testing

@MainActor
@Suite("ArticleRemoteSyncService")
struct ArticleRemoteSyncServiceTests {
    @Test("imports remote article not present locally")
    func importsRemoteArticle() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let mockClient = MockAPIClient()
        mockClient.articles = [
            ArticleDTO(
                id: "remote-1",
                title: "Remote Article",
                author: "Web Author",
                publishedAt: ISO8601DateFormatter().date(from: "2024-05-01T10:00:00Z")!,
                summary: "From web",
                content: "Remote body",
                updatedAt: ISO8601DateFormatter().date(from: "2024-05-01T10:00:00Z")!
            )
        ]

        let service = ArticleRemoteSyncService(
            modelContext: context,
            api: RemoteArticleAPI(client: mockClient)
        )
        try await service.sync()

        let repository = SwiftDataArticleRepository(
            modelContext: context,
            remoteSyncSettings: RemoteSyncSettingsStore(),
            deletionStore: PendingRemoteDeletionStore(),
            seeder: DemoArticleSeeder(),
            syncService: nil
        )
        let articles = try await repository.fetchArticles()
        #expect(articles.contains { $0.id == "remote-1" })
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([ArticleModel.self, FavoriteArticleModel.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [config])
    }
}

private final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    var articles: [ArticleDTO] = []

    func request<T>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T where T: Decodable, T: Sendable {
        if endpoint.method == .get, T.self == [ArticleDTO].self {
            return articles as! T
        }
        if endpoint.method == .post, T.self == ArticleDTO.self, let body = endpoint.body {
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
