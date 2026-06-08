import Foundation

@MainActor
public struct UpdateThemeUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(theme: AppTheme) async throws {
        try await repository.saveTheme(theme)
    }
}
