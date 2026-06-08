# ADR-001: Architecture Selection

**Status**: Accepted  
**Date**: 2026-06-08  
**Deciders**: Project author

## Context

The SwiftUI Architecture Showcase is a portfolio project whose primary goal is demonstrating how a Senior iOS Engineer structures, scales, tests, and maintains a modern SwiftUI application. The application domain (Articles reader with favorites and settings) is intentionally simple so evaluators focus on engineering quality rather than business complexity.

The project must support:
- Independent testing of business logic
- Module boundaries enforced at compile time
- Swappable data sources (local JSON → remote API)
- Clear separation between UI, business rules, and infrastructure

## Decision

Adopt **Clean Architecture** with **MVVM** in the Presentation layer, organized as **Swift Package Manager modules**.

### Layer mapping

| Clean Architecture Layer | Project Module(s) |
|--------------------------|-------------------|
| Entities & Use Cases | `Domain` |
| Interface Adapters (Repositories, Mappers) | `Data` |
| Frameworks & Drivers (HTTP, Logging) | `Networking`, `Core` |
| Presentation (UI + ViewModels) | `Feature*`, `DesignSystem`, `showcase` (App) |

### MVVM within Features

- **View**: SwiftUI struct — rendering and user events only
- **ViewModel**: `@Observable` class — holds `ViewState`, calls Use Cases
- **Model**: Domain entities — never DTOs or persistence models

## Trade-offs

| Benefit | Cost |
|---------|------|
| Strong compile-time module boundaries | More packages to configure and maintain |
| Business logic fully unit-testable without UI | More files and indirection for a simple domain |
| Data source swap without UI changes | Initial setup overhead (DI container, protocols) |
| Portfolio demonstrates Senior-level patterns | Slower initial development vs. single-file prototype |

## Alternatives Considered

### MVC

**Rejected**: In SwiftUI, MVC tends to produce Massive Views or requires UIViewController wrappers. Business logic leaks into views, failing FR-013 and portfolio demonstration goals.

### MVVM-only (no Use Cases)

**Rejected**: ViewModels would absorb business logic, growing into Massive ViewModels. Does not demonstrate Clean Architecture or Single Responsibility Principle adequately.

### VIPER

**Rejected**: Five roles (View, Interactor, Presenter, Entity, Router) per screen is excessive ceremony for ~4 screens. Increases file count without proportional portfolio value.

### TCA (The Composable Architecture)

**Rejected**: Third-party dependency contradicts the no-external-UI-frameworks constraint. While excellent for state management, it shifts the portfolio narrative away from Apple's native patterns.

### Single-target monolith

**Rejected**: No compile-time enforcement of layer boundaries. Reviewers cannot assess modularization skills from folder structure alone.

## Consequences

- Every feature addition follows: Entity → Use Case → Repository Protocol → Implementation → ViewModel → View
- Domain module has zero platform dependencies
- New engineers onboard via architecture.md and this ADR before writing code
- Complexity is justified and documented in plan.md Complexity Tracking table
