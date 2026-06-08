import Core
import Foundation

public enum ArticleValidator {
    public static let minimumTitleLength = 3

    public static func validate(_ draft: ArticleDraft) throws {
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let author = draft.author.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = draft.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = draft.content.trimmingCharacters(in: .whitespacesAndNewlines)

        if title.isEmpty {
            throw DomainError.validationFailed("Title is required.")
        }
        if title.count < minimumTitleLength {
            throw DomainError.validationFailed("Title must be at least \(minimumTitleLength) characters.")
        }
        if author.isEmpty {
            throw DomainError.validationFailed("Author is required.")
        }
        if summary.isEmpty {
            throw DomainError.validationFailed("Summary is required.")
        }
        if content.isEmpty {
            throw DomainError.validationFailed("Content is required.")
        }
    }

    public static func normalized(_ draft: ArticleDraft) -> ArticleDraft {
        ArticleDraft(
            title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
            author: draft.author.trimmingCharacters(in: .whitespacesAndNewlines),
            summary: draft.summary.trimmingCharacters(in: .whitespacesAndNewlines),
            content: draft.content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
