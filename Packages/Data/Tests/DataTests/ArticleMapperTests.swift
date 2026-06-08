@testable import Data
import Foundation
import Testing

@Suite("ArticleMapper")
struct ArticleMapperTests {
    @Test("maps dto to domain entity")
    func mapping() {
        let dto = ArticleDTO(
            id: "test-id",
            title: "Title",
            author: "Author",
            publishedAt: Date(timeIntervalSince1970: 0),
            summary: "Summary",
            content: "Content"
        )
        let article = ArticleMapper.toDomain(dto)
        #expect(article.id == "test-id")
        #expect(article.title == "Title")
    }
}
