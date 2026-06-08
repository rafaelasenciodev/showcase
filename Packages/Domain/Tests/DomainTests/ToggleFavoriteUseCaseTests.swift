import Domain
import SharedTesting
import Testing

@MainActor
@Suite("ToggleFavoriteUseCase")
struct ToggleFavoriteUseCaseTests {
    @Test("toggles favorite state")
    func toggle() async throws {
        let repository = MockFavoriteRepository()
        let useCase = ToggleFavoriteUseCase(repository: repository)
        let added = try await useCase.execute(articleId: "swift-concurrency-2024")
        #expect(added == true)
        let removed = try await useCase.execute(articleId: "swift-concurrency-2024")
        #expect(removed == false)
    }
}
