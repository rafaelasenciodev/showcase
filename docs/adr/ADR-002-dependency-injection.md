# ADR-002: Dependency Injection Strategy

**Status**: Accepted  
**Date**: 2026-06-08  
**Deciders**: Project author

## Context

The application spans 9+ modules with multiple implementations of repository protocols (local JSON, remote API, SwiftData). Objects that need dependencies include:

- Use Cases (require repository protocols)
- ViewModels (require use cases)
- Repositories (require data sources and mappers)
- API Client (requires URLSession and configuration)

The spec explicitly forbids:
- Singletons (`NetworkManager.shared`)
- Static shared managers
- Tight coupling between Feature modules and Data implementations

ViewModels and Use Cases must be unit-testable with mock dependencies injected in tests.

## Decision

Use **protocol-oriented constructor injection** with a centralized **`DependencyContainer`** in the `Core` module, extended in the App target for composition.

### Rules

1. **Constructor injection**: Every type declares dependencies as `private let` properties set via `init`
2. **Protocol types only**: Depend on `ArticleRepositoryProtocol`, never `LocalArticleRepository`
3. **Single composition root**: `showcaseApp` creates the container; passes ViewModels to Views
4. **No service locator**: No `Container.resolve<T>()` from deep inside business logic
5. **Test overrides**: Tests construct objects directly with mocks — no container needed

### Container structure

```swift
// Core — protocol for testability
protocol DependencyContaining {
    func makeArticlesListViewModel() -> ArticlesListViewModel
    func makeArticleDetailViewModel(articleId: String) -> ArticleDetailViewModel
    // ...
}

// App — live implementation
final class LiveDependencyContainer: DependencyContaining {
    private let articleRepository: ArticleRepositoryProtocol
    private let favoriteRepository: FavoriteRepositoryProtocol
    // wired in init(configuration:)
}
```

### SwiftUI integration

- App-level: container creates ViewModels, passes via initializer to root views
- Previews: `PreviewDependencyContainer` with mock repositories in `SharedTesting`
- `@Environment`: used only for `ModelContext` (SwiftData) and theme — not for repositories

## Trade-offs

| Benefit | Cost |
|---------|------|
| Dependencies explicit in every type signature | Verbose initializer lists |
| Trivial to mock in tests | Container grows as features are added |
| No hidden global state | Manual wiring on each new ViewModel |
| Compile-time safety on protocol conformance | Requires discipline to avoid convenience singletons |

## Alternatives Considered

### Singleton / shared instance pattern

**Rejected**: Explicitly forbidden by spec. Creates hidden dependencies, complicates testing, and signals junior-level patterns to portfolio reviewers.

### `@Environment` injection for all dependencies

**Rejected**: Dependencies become implicit — reading a View's code does not reveal what it needs. ViewModel testing requires environment setup boilerplate. Acceptable for system values (color scheme) but not for business dependencies.

### Swinject / Factory third-party DI

**Rejected**: Adds external dependency for a project with ~10 wired types. Constructor injection + container is sufficient and demonstrates native Swift fluency.

### Protocol-less concrete injection

**Rejected**: Tests would depend on concrete types. Swapping local → remote repository would require ViewModel changes.

## Consequences

- Adding a new feature requires: protocol (if new) → implementation → use case → container factory method → view
- `SharedTesting` provides `MockArticleRepository`, `MockFavoriteRepository` conforming to protocols
- Code review checklist includes: "Does this type access `.shared` or create its own URLSession?"
