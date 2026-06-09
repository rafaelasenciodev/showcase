import Foundation

struct RemoteArticlePayload: Codable, Sendable {
    let id: String
    let title: String
    let author: String
    let publishedAt: Date
    let summary: String
    let content: String
    let updatedAt: Date

    init(from model: ArticleModel) {
        id = model.id
        title = model.title
        author = model.author
        publishedAt = model.publishedAt
        summary = model.summary
        content = model.content
        updatedAt = model.updatedAt
    }
}
