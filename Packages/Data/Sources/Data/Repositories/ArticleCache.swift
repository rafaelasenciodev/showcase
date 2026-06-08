import Domain
import Foundation

actor ArticleCache {
    private var articles: [Article] = []

    func get() -> [Article] { articles }
    func isEmpty() -> Bool { articles.isEmpty }
    func set(_ articles: [Article]) { self.articles = articles }
}
