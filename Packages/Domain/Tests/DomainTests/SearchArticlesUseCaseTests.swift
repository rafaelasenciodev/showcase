import Domain
import SharedTesting
import Testing

@Suite("SearchArticlesUseCase")
struct SearchArticlesUseCaseTests {
    @Test("filters by title")
    func filterByTitle() {
        let useCase = SearchArticlesUseCase()
        let query = SearchQuery(text: "swiftdata")
        let result = useCase.execute(query: query, articles: ArticleFixtures.samples)
        #expect(result.count == 1)
        #expect(result.first?.id == "swiftdata-favorites")
    }
}
