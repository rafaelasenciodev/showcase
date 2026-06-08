import Foundation

public struct SearchArticlesUseCase: Sendable {
    public init() {}

    public func execute(query: SearchQuery, articles: [Article]) -> [Article] {
        guard !query.isEmpty else { return articles }
        let term = query.text.lowercased()
        return articles.filter { article in
            article.title.lowercased().contains(term)
                || article.summary.lowercased().contains(term)
                || article.content.lowercased().contains(term)
        }
    }
}
