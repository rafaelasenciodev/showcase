import Foundation
import Network
import Observation

@MainActor
@Observable
public final class NetworkConnectivityMonitor {
    public private(set) var isConnected = true
    public private(set) var shouldShowBackOnlineBanner = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.showcase.network-monitor")

    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            Task { @MainActor [weak self] in
                guard let self else { return }
                if connected && !self.isConnected {
                    self.shouldShowBackOnlineBanner = true
                }
                self.isConnected = connected
            }
        }
        monitor.start(queue: queue)
    }

    public func dismissBackOnlineBanner() {
        shouldShowBackOnlineBanner = false
    }
}
