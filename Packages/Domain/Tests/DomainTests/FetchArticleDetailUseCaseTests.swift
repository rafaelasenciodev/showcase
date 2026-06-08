import Core
import Domain
import SharedTesting
import Testing

@Suite("FetchArticleDetailUseCase")
struct FetchArticleDetailUseCaseTests {
    @Test("returns article for valid id")
    func validID() async throws {
        let repository = MockArticleRepository()
        let useCase = FetchArticleDetailUseCase(repository: repository)
        let article = try await useCase.execute(id: "swift-concurrency-2024")
        #expect(article.title == "Understanding Swift Concurrency")
    }

    @Test("throws notFound for empty id")
    func emptyID() async throws {
        let repository = MockArticleRepository()
        let useCase = FetchArticleDetailUseCase(repository: repository)
        await #expect(throws: DomainError.notFound) {
            try await useCase.execute(id: "")
        }
    }
}
