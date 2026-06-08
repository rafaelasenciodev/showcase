import Foundation

@MainActor
public struct FetchSettingsUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() async -> AppSettings {
        await repository.fetchSettings()
    }
}
