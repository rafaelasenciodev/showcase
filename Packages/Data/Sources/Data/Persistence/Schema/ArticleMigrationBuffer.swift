import Foundation

enum ArticleMigrationBuffer {
    struct Snapshot: Sendable {
        let id: String
        let title: String
        let author: String
        let publishedAt: Date
        let summary: String
        let content: String
        let isDemoSeed: Bool
    }

    /// Migration stages run synchronously during container init; unsafe storage avoids Sendable friction.
    nonisolated(unsafe) static var pending: [Snapshot] = []
}
