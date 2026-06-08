import Foundation

public enum ArticleEndpoints {
    public static var listArticles: Endpoint {
        Endpoint(
            path: "/articles",
            method: .get,
            headers: ["Accept": "application/json"]
        )
    }

    public static func getArticle(id: String) -> Endpoint {
        Endpoint(
            path: "/articles/\(id)",
            method: .get,
            headers: ["Accept": "application/json"]
        )
    }
}
