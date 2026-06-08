import FeatureArticles
import SwiftUI

struct ArticlesNavigationStack: View {
    let container: LiveDependencyContainer

    var body: some View {
        NavigationStack {
            ArticlesListView(viewModel: container.articlesListViewModel)
                .navigationDestination(for: String.self) { articleId in
                    ArticleDetailView(viewModel: container.makeArticleDetailViewModel(articleId: articleId))
                }
        }
    }
}
