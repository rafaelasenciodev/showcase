import Foundation

@MainActor
public struct UpdateRemoteSyncUseCase {
    private let repository: SettingsRepositoryProtocol

    public init(repository: SettingsRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(enabled: Bool) async throws {
        try await repository.saveRemoteSyncEnabled(enabled)
    }
}
