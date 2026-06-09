# ADR-003: Local JSON vs Remote API Strategy

**Status**: Accepted  
**Date**: 2026-06-08  
**Deciders**: Project author

## Context

The Articles app needs a catalog of demo content. The portfolio must demonstrate:

1. A working app in Phase 1 without external API dependencies (reliable CI, offline demo)
2. A complete networking layer showing URLSession, endpoints, and error handling skills
3. Dependency Inversion — swapping data sources without touching Presentation layer

Constraints:
- No real production API available at project start
- CI must build and test without network access
- Reviewers must see the swap path documented and implemented

## Decision

Implement a **two-phase data strategy** behind a unified `ArticleRepositoryProtocol`:

### Phase 1 (Default — Active)

- Persist articles in **SwiftData** via `SwiftDataArticleRepository`
- Full **CRUD** (create, read, update, delete) with cascade delete for favorites
- `articles.json` remains bundled as **demo seed** only (first launch + Settings restore)
- `LocalJSONArticleDataSource` imports demo content; user-created articles are stored separately (`isDemoSeed` flag)
- DI container wires SwiftData implementation by default (`.local` configuration)

### Phase 2 (Active — hybrid sync)

- `Networking` module: `URLSessionAPIClient`, CRUD endpoints, mockapi.io integration
- `ArticleRemoteSyncService`: pull → merge (LWW by `updatedAt`) → push on pull-to-refresh
- Demo articles (`isDemoSeed`) remain local-only; user-created articles sync to remote
- Remote deletions propagate to the app on sync; favorites cascade locally
- Settings toggle **Remote Sync** (default on); URL hardcoded to mockapi project
- See [ADR-003](adr/ADR-003-local-json-vs-remote-api.md)

### Shared contract

Both sources produce `ArticleDTO` → mapped to `Article` via `ArticleMapper`. The Domain layer sees identical `[Article]` regardless of source.

```swift
enum DataSourceConfiguration {
    case local
    case remote(baseURL: URL)
}
```

## Trade-offs

| Benefit | Cost |
|---------|------|
| Phase 1 works offline with zero network flakiness | Two repository/data source implementations to maintain |
| CI always green without mock servers | Remote path untested against real API until configured |
| Single mapper and DTO schema | JSON schema must stay compatible with future API |
| Clear portfolio narrative for dependency inversion | Slight over-engineering for static demo data |

## Alternatives Considered

### Local JSON only (no networking module)

**Rejected**: Fails FR-019. Does not demonstrate URLSession, endpoint design, or network error handling — key Senior iOS evaluation criteria.

### Remote API only with mock server in CI

**Rejected**: Introduces CI flakiness and infrastructure dependency. Portfolio reviewers cloning the repo would need a running server. Violates SC-004 (first-attempt success from clean clone).

### Core Data cache + remote

**Rejected**: Over-engineered for static demo articles. Adds persistence complexity without portfolio value for the read-only catalog. May be revisited as future improvement.

### Hard-coded articles in Swift arrays

**Rejected**: No demonstration of decoding, DTO mapping, or data source abstraction. Looks like tutorial-level code.

### Protocol with single implementation (local), networking as dead code

**Rejected**: Networking module must be wired through DI and tested with `URLProtocol` mocks. Dead code undermines portfolio credibility.

## Consequences

- `articles.json` contains sample articles for demo seed and restore
- `DataTests` covers `SwiftDataArticleRepository` CRUD and legacy `LocalArticleRepository` JSON loading
- README documents CRUD flows and Settings → Restore Demo Articles
- Pull-to-refresh reloads from SwiftData (ready for future iCloud sync or remote merge)

## Verification

To confirm dependency inversion works:

1. Run app with `.local` — articles load from bundle
2. Switch DI to `.remote(baseURL:)` with mock `URLProtocol` — articles load from mock HTTP
3. Confirm zero changes in `FeatureArticles` source files between steps
