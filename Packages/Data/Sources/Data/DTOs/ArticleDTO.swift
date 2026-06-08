import Foundation

struct ArticleDTO: Codable, Sendable, Equatable {
    let id: String
    let title: String
    let author: String
    let publishedAt: Date
    let summary: String
    let content: String
}

struct ArticlesResponseDTO: Codable, Sendable, Equatable {
    let articles: [ArticleDTO]
}
