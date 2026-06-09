#if os(iOS)
import Core
import DesignSystem
import Domain
import FeatureArticlesCore
import SwiftUI

public struct ArticlesListView: View {
    @Bindable private var viewModel: ArticlesListViewModel

    @State private var isCreating = false
    @State private var articlePendingDeletion: Article?
    @State private var deletionError: String?

    private let makeEditorViewModel: () -> ArticleEditorViewModel

    public init(
        viewModel: ArticlesListViewModel,
        makeEditorViewModel: @escaping () -> ArticleEditorViewModel
    ) {
        self.viewModel = viewModel
        self.makeEditorViewModel = makeEditorViewModel
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
                        ? "Tap + to create your first article."
                        : "Try a different search term.",
                    actionTitle: viewModel.searchText.isEmpty ? "Create Article" : "Clear Search",
                    action: viewModel.searchText.isEmpty
                        ? { isCreating = true }
                        : { viewModel.searchText = "" }
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            articlePendingDeletion = article
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
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
        .overlay(alignment: .top) {
            if viewModel.networkMonitor.shouldShowBackOnlineBanner {
                Text("Back online — pull down to sync")
                    .font(AppTypography.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
                    .padding(.top, 8)
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search articles")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isCreating = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Create article")
            }
        }
        .sheet(isPresented: $isCreating, onDismiss: {
            Task { await viewModel.refresh() }
        }) {
            ArticleEditorView(viewModel: makeEditorViewModel())
        }
        .confirmationDialog(
            "Delete Article?",
            isPresented: Binding(
                get: { articlePendingDeletion != nil },
                set: { if !$0 { articlePendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                guard let article = articlePendingDeletion else { return }
                Task {
                    do {
                        try await viewModel.delete(article)
                        articlePendingDeletion = nil
                    } catch {
                        deletionError = (error as? DomainError)?.userMessage ?? DomainError.loadFailed.userMessage
                        articlePendingDeletion = nil
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                articlePendingDeletion = nil
            }
        } message: {
            Text("This action cannot be undone. Any favorites for this article will also be removed.")
        }
        .alert(
            "Unable to Delete",
            isPresented: Binding(
                get: { deletionError != nil },
                set: { if !$0 { deletionError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { deletionError = nil }
        } message: {
            Text(deletionError ?? "")
        }
        .task {
            await viewModel.onAppear()
        }
    }
}
#endif
