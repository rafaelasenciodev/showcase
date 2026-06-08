import Domain
import SharedTesting
import Testing

@Suite("FetchArticlesUseCase")
struct FetchArticlesUseCaseTests {
    @Test("returns articles sorted by date descending")
    func sortedArticles() async throws {
        let repository = MockArticleRepository(articles: ArticleFixtures.samples)
        let useCase = FetchArticlesUseCase(repository: repository)
        let result = try await useCase.execute()
        #expect(result.count == 3)
        #expect(result.first?.id == "swift-concurrency-2024")
    }
}
