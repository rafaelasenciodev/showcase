import DesignSystem
import Domain
import SwiftUI

public struct ArticlesListView: View {
    @Bindable private var viewModel: ArticlesListViewModel

    public init(viewModel: ArticlesListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            switch viewModel.viewState {
            case .idle, .loading:
                LoadingView(message: "Loading articles...")
            case .empty:
                EmptyStateView(
                    title: viewModel.searchText.isEmpty ? "No Articles" : "No Results",
                    message: viewModel.searchText.isEmpty
                        ? "Articles will appear here once loaded."
                        : "Try a different search term.",
                    actionTitle: viewModel.searchText.isEmpty ? nil : "Clear Search",
                    action: viewModel.searchText.isEmpty ? nil : { viewModel.searchText = "" }
                )
            case let .loaded(articles):
                List(articles) { article in
                    NavigationLink(value: article.id) {
                        ArticleRowView(
                            article: article,
                            isFavorite: viewModel.isFavorite(article),
                            onFavoriteTap: {
                                Task { await viewModel.toggleFavorite(for: article) }
                            }
                        )
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .listStyle(.plain)
                .refreshable {
                    await viewModel.refresh()
                }
            case let .error(message):
                ErrorStateView(message: message) {
                    Task { await viewModel.onAppear() }
                }
            }
        }
        .navigationTitle("Articles")
        .searchable(text: $viewModel.searchText, prompt: "Search articles")
        .task {
            await viewModel.onAppear()
        }
    }
}
