#if os(iOS)
import Core
import DesignSystem
import Domain
import FeatureArticlesCore
import SwiftUI

public struct ArticleDetailView: View {
    @Bindable private var viewModel: ArticleDetailViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var isDeleteConfirmationPresented = false
    @State private var actionError: String?

    private let makeEditorViewModel: (Article) -> ArticleEditorViewModel

    public init(
        viewModel: ArticleDetailViewModel,
        makeEditorViewModel: @escaping (Article) -> ArticleEditorViewModel
    ) {
        self.viewModel = viewModel
        self.makeEditorViewModel = makeEditorViewModel
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                if viewModel.currentArticle != nil {
                    Button {
                        isEditing = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("Edit article")

                    Button(role: .destructive) {
                        isDeleteConfirmationPresented = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete article")
                }

                Button {
                    Task { await viewModel.toggleFavorite() }
                } label: {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isFavorite ? .red : AppColors.textPrimary)
                }
            }
        }
        .sheet(isPresented: $isEditing, onDismiss: {
            Task { await viewModel.onAppear() }
        }) {
            if let article = viewModel.currentArticle {
                ArticleEditorView(viewModel: makeEditorViewModel(article))
            }
        }
        .confirmationDialog(
            "Delete Article?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await viewModel.delete()
                        dismiss()
                    } catch {
                        actionError = (error as? DomainError)?.userMessage ?? DomainError.loadFailed.userMessage
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. Any favorites for this article will also be removed.")
        }
        .alert(
            "Unable to Delete",
            isPresented: Binding(
                get: { actionError != nil },
                set: { if !$0 { actionError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { actionError = nil }
        } message: {
            Text(actionError ?? "")
        }
        .task {
            await viewModel.onAppear()
        }
    }
}
#endif
