import Foundation

public protocol Logger: Sendable {
    func debug(_ message: String)
    func info(_ message: String)
    func error(_ message: String)
}

public struct DefaultLogger: Logger {
    private let subsystem: String

    public init(subsystem: String = "com.rafaelasencio.showcase") {
        self.subsystem = subsystem
    }

    public func debug(_ message: String) {
        log(level: "DEBUG", message: message)
    }

    public func info(_ message: String) {
        log(level: "INFO", message: message)
    }

    public func error(_ message: String) {
        log(level: "ERROR", message: message)
    }

    private func log(level: String, message: String) {
        #if DEBUG
        print("[\(level)] [\(subsystem)] \(message)")
        #endif
    }
}
