import Foundation

@MainActor
public protocol SettingsRepositoryProtocol {
    func fetchSettings() async -> AppSettings
    func saveTheme(_ theme: AppTheme) async throws
}
