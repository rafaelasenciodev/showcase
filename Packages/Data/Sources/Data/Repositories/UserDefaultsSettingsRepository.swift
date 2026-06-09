import Domain
import Foundation

@MainActor
public final class UserDefaultsSettingsRepository: SettingsRepositoryProtocol {
    private let defaults: UserDefaults
    private let themeKey = "app_theme"
    private let remoteSyncKey = "remote_sync_enabled"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func fetchSettings() async -> AppSettings {
        let themeRaw = defaults.string(forKey: themeKey) ?? AppTheme.system.rawValue
        let theme = AppTheme(rawValue: themeRaw) ?? .system
        return AppSettings(
            theme: theme,
            appVersion: Bundle.main.appVersion,
            architectureInfo: Self.architectureInfo,
            isRemoteSyncEnabled: isRemoteSyncEnabled
        )
    }

    public func saveTheme(_ theme: AppTheme) async throws {
        defaults.set(theme.rawValue, forKey: themeKey)
    }

    public func saveRemoteSyncEnabled(_ enabled: Bool) async throws {
        defaults.set(enabled, forKey: remoteSyncKey)
    }

    private var isRemoteSyncEnabled: Bool {
        if defaults.object(forKey: remoteSyncKey) == nil {
            return true
        }
        return defaults.bool(forKey: remoteSyncKey)
    }

    private static let architectureInfo = """
    SwiftUI Architecture Showcase demonstrates Clean Architecture with MVVM, \
    SPM modularization, protocol-oriented dependency injection, and the Repository pattern. \
    Domain defines contracts; Data and Networking provide implementations swappable via DI.
    """
}

private extension Bundle {
    var appVersion: String {
        (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
    }
}
