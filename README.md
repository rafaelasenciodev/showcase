# SwiftUI Architecture Showcase

Production-inspired iOS portfolio project demonstrating **Clean Architecture**, **MVVM**, **SPM modularization**, **dependency injection**, and **comprehensive testing**.

The Articles app (list, search, detail, favorites, settings) is intentionally simple — the focus is engineering quality, not feature complexity.

## Architecture

```mermaid
graph TB
    App[showcase App] --> FeatureArticles
    App --> FeatureFavorites
    App --> FeatureSettings
    App --> Data
    FeatureArticles --> Domain
    FeatureArticles --> DesignSystem
    FeatureFavorites --> Domain
    FeatureSettings --> Domain
    Data --> Domain
    Data --> Networking
    Domain --> Core
    DesignSystem --> Core
    Networking --> Core
```

See [docs/architecture.md](docs/architecture.md) for layer responsibilities, dependency rules, and testing strategy.

## Modules

```text
Packages/
├── Core/              # Errors, logging, ViewState
├── Domain/            # Entities, use cases, repository protocols
├── Data/              # Repositories, DTOs, mappers, SwiftData
├── Networking/        # URLSession client and endpoints
├── DesignSystem/      # Reusable UI components
├── FeatureArticles/   # List, detail, search
├── FeatureFavorites/  # Favorites tab
├── FeatureSettings/   # Theme and app info
└── SharedTesting/     # Fixtures and mocks
```

## Getting Started

```bash
git clone <repository-url>
cd showcase
open showcase.xcodeproj
```

Run on an iOS 17+ simulator (⌘R).

```bash
xcodebuild build -scheme showcase \
  -destination 'platform=iOS Simulator,name=iPhone 17'

xcodebuild test -scheme showcase \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Package-level tests:

```bash
cd Packages/Domain && swift test
cd ../Data && swift test
```

## Architectural Decisions

| ADR | Topic |
|-----|-------|
| [ADR-001](docs/adr/ADR-001-architecture-selection.md) | Clean Architecture + MVVM |
| [ADR-002](docs/adr/ADR-002-dependency-injection.md) | Constructor injection |
| [ADR-003](docs/adr/ADR-003-local-json-vs-remote-api.md) | Local JSON vs remote API |

## Testing

- **Swift Testing** — domain use cases, repositories, mappers, ViewModels
- **XCTest** — UI smoke tests
- **SharedTesting** — reusable mocks and fixtures across packages

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs build, tests, and SPM package validation on every push.

## Requirements

- Xcode 16+
- iOS 17+ deployment target
- Swift 6

## License

Available for portfolio and evaluation purposes. See repository settings for license details.
