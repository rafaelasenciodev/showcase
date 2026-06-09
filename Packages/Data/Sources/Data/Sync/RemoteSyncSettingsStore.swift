import Foundation

public struct RemoteSyncSettingsStore {
    private let defaults: UserDefaults
    private let enabledKey = "remote_sync_enabled"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var isEnabled: Bool {
        if defaults.object(forKey: enabledKey) == nil {
            return true
        }
        return defaults.bool(forKey: enabledKey)
    }

    public func setEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: enabledKey)
    }
}
