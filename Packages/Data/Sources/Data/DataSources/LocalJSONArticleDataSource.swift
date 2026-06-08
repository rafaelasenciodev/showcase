import Core
import Foundation

protocol ArticleDataSource: Sendable {
    func loadArticles() async throws -> [ArticleDTO]
}

struct LocalJSONArticleDataSource: ArticleDataSource {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .module) {
        self.bundle = bundle
        self.decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadArticles() async throws -> [ArticleDTO] {
        guard let url = bundle.url(forResource: "articles", withExtension: "json") else {
            throw DomainError.loadFailed
        }
        do {
            let data = try Data(contentsOf: url)
            let response = try decoder.decode(ArticlesResponseDTO.self, from: data)
            let ids = Set(response.articles.map(\.id))
            guard ids.count == response.articles.count else {
                throw DomainError.decodingFailed
            }
            return response.articles
        } catch let error as DomainError {
            throw error
        } catch {
            throw DomainError.decodingFailed
        }
    }
}
