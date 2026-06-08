#if os(iOS)
import DesignSystem
import Domain
import FeatureFavoritesCore
import SwiftUI

public struct FavoritesListView: View {
    @Bindable private var viewModel: FavoritesViewModel

    public init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                LoadingView(message: "Loading favorites...")
            case .empty:
                EmptyStateView(
                    title: "No Favorites",
                    message: "Articles you favorite will appear here."
                )
            case let .loaded(articles):
                List(articles) { article in
                    AppCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(article.title)
                                .font(AppTypography.headline)
                            Text(article.author)
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task { await viewModel.removeFavorite(article) }
                        } label: {
                            Label("Remove", systemImage: "heart.slash")
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .listStyle(.plain)
            case let .error(message):
                ErrorStateView(message: message) {
                    Task { await viewModel.onAppear() }
                }
            }
        }
        .navigationTitle("Favorites")
        .task {
            await viewModel.onAppear()
        }
    }
}
#endif
