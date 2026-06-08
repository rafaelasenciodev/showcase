import Domain
import SharedTesting
import Testing

@Suite("RefreshArticlesUseCase")
struct RefreshArticlesUseCaseTests {
    @Test("returns refreshed articles")
    func refresh() async throws {
        let repository = MockArticleRepository()
        let useCase = RefreshArticlesUseCase(repository: repository)
        let result = try await useCase.execute()
        #expect(!result.isEmpty)
    }
}
