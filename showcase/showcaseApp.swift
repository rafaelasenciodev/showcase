import Data
import Domain
import SwiftData
import SwiftUI

@main
struct showcaseApp: App {
    @State private var selectedTheme: AppTheme = .system

    private let modelContainer: ModelContainer
    private let dependencyContainer: LiveDependencyContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: FavoriteArticleModel.self, ArticleModel.self)
            dependencyContainer = LiveDependencyContainer(
                modelContext: modelContainer.mainContext
            )
            selectedTheme = Self.loadSavedTheme()
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView(container: dependencyContainer, selectedTheme: $selectedTheme)
                .preferredColorScheme(colorScheme)
                .task {
                    try? await dependencyContainer.seedArticlesIfNeeded()
                }
        }
        .modelContainer(modelContainer)
    }

    private var colorScheme: ColorScheme? {
        switch selectedTheme {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    private static func loadSavedTheme() -> AppTheme {
        let raw = UserDefaults.standard.string(forKey: "app_theme") ?? AppTheme.system.rawValue
        return AppTheme(rawValue: raw) ?? .system
    }
}
