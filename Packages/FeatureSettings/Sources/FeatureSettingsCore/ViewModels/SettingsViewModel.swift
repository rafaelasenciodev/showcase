import Core
import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class SettingsViewModel {
    public private(set) var settings: AppSettings?
    public private(set) var viewState: ViewState<AppSettings> = .idle
    public private(set) var restoreMessage: String?

    private let fetchSettings: FetchSettingsUseCase
    private let updateTheme: UpdateThemeUseCase
    private let restoreDemoArticles: RestoreDemoArticlesUseCase

    public var onThemeChanged: ((AppTheme) -> Void)?
    public var onDemoArticlesRestored: (() async -> Void)?

    public init(
        fetchSettings: FetchSettingsUseCase,
        updateTheme: UpdateThemeUseCase,
        restoreDemoArticles: RestoreDemoArticlesUseCase
    ) {
        self.fetchSettings = fetchSettings
        self.updateTheme = updateTheme
        self.restoreDemoArticles = restoreDemoArticles
    }

    public func onAppear() async {
        let loaded = await fetchSettings.execute()
        settings = loaded
        viewState = .loaded(loaded)
    }

    public func selectTheme(_ theme: AppTheme) async {
        do {
            try await updateTheme.execute(theme: theme)
            let current: AppSettings
            if let settings {
                current = settings
            } else {
                current = await fetchSettings.execute()
            }
            let updated = AppSettings(
                theme: theme,
                appVersion: current.appVersion,
                architectureInfo: current.architectureInfo
            )
            settings = updated
            viewState = .loaded(updated)
            onThemeChanged?(theme)
        } catch {
            viewState = .error(DomainError.persistenceFailed.userMessage)
        }
    }

    public func restoreDemoContent() async {
        restoreMessage = nil
        do {
            let count = try await restoreDemoArticles.execute()
            restoreMessage = "\(count) demo articles restored."
            await onDemoArticlesRestored?()
        } catch let error as DomainError {
            restoreMessage = error.userMessage
        } catch {
            restoreMessage = DomainError.loadFailed.userMessage
        }
    }
}
