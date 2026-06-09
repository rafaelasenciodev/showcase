import Foundation

public enum ArticleEndpoints {
    public static var listArticles: Endpoint {
        Endpoint(
            path: "/articles",
            method: .get,
            headers: jsonHeaders
        )
    }

    public static func createArticle(body: Data) -> Endpoint {
        Endpoint(
            path: "/articles",
            method: .post,
            headers: jsonHeaders,
            body: body
        )
    }

    public static func updateArticle(id: String, body: Data) -> Endpoint {
        Endpoint(
            path: "/articles/\(id)",
            method: .put,
            headers: jsonHeaders,
            body: body
        )
    }

    public static func deleteArticle(id: String) -> Endpoint {
        Endpoint(
            path: "/articles/\(id)",
            method: .delete,
            headers: jsonHeaders
        )
    }

    public static func getArticle(id: String) -> Endpoint {
        Endpoint(
            path: "/articles/\(id)",
            method: .get,
            headers: jsonHeaders
        )
    }

    private static let jsonHeaders = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
}
