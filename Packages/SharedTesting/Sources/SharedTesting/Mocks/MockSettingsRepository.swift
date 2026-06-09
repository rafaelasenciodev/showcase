import Domain
import Foundation

@MainActor
public final class MockSettingsRepository: SettingsRepositoryProtocol {
    public var settings: AppSettings

    public init(settings: AppSettings = AppSettings(
        theme: .system,
        appVersion: "1.0",
        architectureInfo: "Test architecture info",
        isRemoteSyncEnabled: true
    )) {
        self.settings = settings
    }

    public func fetchSettings() async -> AppSettings {
        settings
    }

    public func saveTheme(_ theme: AppTheme) async throws {
        settings = AppSettings(
            theme: theme,
            appVersion: settings.appVersion,
            architectureInfo: settings.architectureInfo,
            isRemoteSyncEnabled: settings.isRemoteSyncEnabled
        )
    }

    public func saveRemoteSyncEnabled(_ enabled: Bool) async throws {
        settings = AppSettings(
            theme: settings.theme,
            appVersion: settings.appVersion,
            architectureInfo: settings.architectureInfo,
            isRemoteSyncEnabled: enabled
        )
    }
}
