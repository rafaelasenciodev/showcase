import Foundation

public enum DataSourceConfiguration: Sendable {
    case local
    case remote(baseURL: URL)
}
