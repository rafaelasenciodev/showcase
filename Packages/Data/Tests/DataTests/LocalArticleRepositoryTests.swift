@testable import Data
import Foundation
import Testing

@Suite("LocalArticleRepository")
struct LocalArticleRepositoryTests {
    @Test("loads bundled articles")
    func loadBundled() async throws {
        let repository = LocalArticleRepository()
        let articles = try await repository.fetchArticles()
        #expect(articles.count >= 3)
    }
}
