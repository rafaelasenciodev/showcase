import Core
import DesignSystem
import Domain
import SwiftUI

public struct ArticleRowView: View {
    private let article: Article
    private let isFavorite: Bool
    private let onFavoriteTap: () -> Void

    public init(article: Article, isFavorite: Bool, onFavoriteTap: @escaping () -> Void) {
        self.article = article
        self.isFavorite = isFavorite
        self.onFavoriteTap = onFavoriteTap
    }

    public var body: some View {
        AppCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(article.author)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(article.publishedAt.articleFormatted)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(article.summary)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Button(action: onFavoriteTap) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : AppColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
