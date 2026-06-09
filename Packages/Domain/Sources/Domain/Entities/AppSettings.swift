import Foundation

public struct AppSettings: Equatable, Sendable {
    public let theme: AppTheme
    public let appVersion: String
    public let architectureInfo: String
    public let isRemoteSyncEnabled: Bool

    public init(
        theme: AppTheme,
        appVersion: String,
        architectureInfo: String,
        isRemoteSyncEnabled: Bool
    ) {
        self.theme = theme
        self.appVersion = appVersion
        self.architectureInfo = architectureInfo
        self.isRemoteSyncEnabled = isRemoteSyncEnabled
    }
}
