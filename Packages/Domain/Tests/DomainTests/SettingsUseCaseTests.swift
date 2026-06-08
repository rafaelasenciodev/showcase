import Domain
import SharedTesting
import Testing

@MainActor
@Suite("FetchSettingsUseCase")
struct FetchSettingsUseCaseTests {
    @Test("returns settings")
    func fetch() async {
        let repository = MockSettingsRepository()
        let useCase = FetchSettingsUseCase(repository: repository)
        let settings = await useCase.execute()
        #expect(settings.appVersion == "1.0")
    }
}

@MainActor
@Suite("UpdateThemeUseCase")
struct UpdateThemeUseCaseTests {
    @Test("updates theme")
    func update() async throws {
        let repository = MockSettingsRepository()
        let useCase = UpdateThemeUseCase(repository: repository)
        try await useCase.execute(theme: .dark)
        let settings = await repository.fetchSettings()
        #expect(settings.theme == .dark)
    }
}
