import Domain
import FeatureSettings
import SharedTesting
import Testing

@MainActor
@Suite("SettingsViewModel")
struct SettingsViewModelTests {
    @Test("loads settings")
    func load() async {
        let repository = MockSettingsRepository()
        let viewModel = SettingsViewModel(
            fetchSettings: FetchSettingsUseCase(repository: repository),
            updateTheme: UpdateThemeUseCase(repository: repository),
            restoreDemoArticles: RestoreDemoArticlesUseCase(repository: MockArticleRepository())
        )
        await viewModel.onAppear()
        #expect(viewModel.settings?.theme == .system)
    }

    @Test("updates theme without clearing settings")
    func selectTheme() async {
        let repository = MockSettingsRepository()
        let viewModel = SettingsViewModel(
            fetchSettings: FetchSettingsUseCase(repository: repository),
            updateTheme: UpdateThemeUseCase(repository: repository),
            restoreDemoArticles: RestoreDemoArticlesUseCase(repository: MockArticleRepository())
        )
        await viewModel.onAppear()
        await viewModel.selectTheme(.dark)
        #expect(viewModel.settings?.theme == .dark)
        if case .loaded = viewModel.viewState {
            // expected
        } else {
            Issue.record("Expected loaded state after theme change")
        }
    }
}
