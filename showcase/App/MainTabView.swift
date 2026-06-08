import Domain
import FeatureArticles
import FeatureFavorites
import FeatureSettings
import SwiftUI

struct MainTabView: View {
    let container: LiveDependencyContainer
    @Binding var selectedTheme: AppTheme

    var body: some View {
        TabView {
            ArticlesNavigationStack(container: container)
                .tabItem {
                    Label("Articles", systemImage: "newspaper")
                }

            NavigationStack {
                FavoritesListView(viewModel: container.favoritesViewModel)
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }

            NavigationStack {
                SettingsView(viewModel: container.settingsViewModel)
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .onAppear {
            container.configureSettings(
                onThemeChanged: { theme in
                    selectedTheme = theme
                },
                onDemoArticlesRestored: {
                    await container.articlesListViewModel.refresh()
                    await container.favoritesViewModel.onAppear()
                }
            )
        }
    }
}
