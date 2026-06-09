import Foundation

@MainActor
public protocol SettingsRepositoryProtocol {
    func fetchSettings() async -> AppSettings
    func saveTheme(_ theme: AppTheme) async throws
    func saveRemoteSyncEnabled(_ enabled: Bool) async throws
}
