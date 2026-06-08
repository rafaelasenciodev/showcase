import FeatureArticlesUI
import SwiftUI

struct ArticlesNavigationStack: View {
    let container: LiveDependencyContainer

    var body: some View {
        NavigationStack {
            ArticlesListView(
                viewModel: container.articlesListViewModel,
                makeEditorViewModel: { container.makeArticleEditorViewModel() }
            )
            .navigationDestination(for: String.self) { articleId in
                ArticleDetailView(
                    viewModel: container.makeArticleDetailViewModel(articleId: articleId),
                    makeEditorViewModel: { article in
                        container.makeArticleEditorViewModel(for: article)
                    }
                )
            }
        }
    }
}
