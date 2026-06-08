import Core
import DesignSystem
import Domain
import SwiftUI

public struct ArticleDetailView: View {
    @Bindable private var viewModel: ArticleDetailViewModel

    public init(viewModel: ArticleDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                LoadingView(message: "Loading article...")
            case let .loaded(article):
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(article.title)
                            .font(AppTypography.largeTitle)
                        HStack {
                            Label(article.author, systemImage: "person.fill")
                            Spacer()
                            Label(article.publishedAt.articleFormatted, systemImage: "calendar")
                        }
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        Divider()
                        Text(article.content)
                            .font(AppTypography.body)
                    }
                    .padding()
                }
            case .empty:
                EmptyStateView(title: "Not Found", message: "This article is no longer available.")
            case let .error(message):
                ErrorStateView(message: message) {
                    Task { await viewModel.onAppear() }
                }
            }
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.toggleFavorite() }
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? .red : AppColors.textPrimary)
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }
}
