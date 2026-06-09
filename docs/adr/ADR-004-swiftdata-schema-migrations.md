# ADR-004: SwiftData Versioned Schema Migrations

**Status**: Accepted  
**Date**: 2026-06-09  
**Deciders**: Project author

## Context

`ArticleModel` gained sync metadata (`updatedAt`, `isOnRemote`, `needsSyncPush`) in the remote API feature. Existing on-device SQLite stores from schema V1 could not be opened: Core Data reported validation errors for mandatory attributes without default values.

Users upgrading the app must keep their articles and favorites.

## Decision

Adopt **SwiftData `VersionedSchema` + `SchemaMigrationPlan`**:

| Version | Models | Purpose |
|---------|--------|---------|
| V1 (`1.0.0`) | nested `ShowcaseSchemaV1.ArticleModel`, `FavoriteArticleModel` | Local CRUD without sync fields; entity name stays `ArticleModel` |
| V2 (`2.0.0`) | `ArticleModel`, `FavoriteArticleModel` | Remote sync metadata |

### Migration stage V1 → V2

Custom `MigrationStage`:

1. **`willMigrate`**: snapshot legacy `ShowcaseSchemaV1.ArticleModel` rows, delete V1 entities
2. **`didMigrate`**: insert `ArticleModel` with defaults — `updatedAt = publishedAt`, `isOnRemote = false`, `needsSyncPush = false`

`ShowcaseModelContainerFactory` centralizes `ModelContainer` creation for the app and tests.

### Unversioned store bootstrap

Stores created before `VersionedSchema` have no stamped version (error `134504`). The factory opens the store once with `ShowcaseSchemaV1` only, then retries with the full migration plan — matching Apple DTS guidance for unversioned → versioned transitions.

## Trade-offs

| Benefit | Cost |
|---------|------|
| Survives real device upgrades | Extra schema types to maintain per version |
| Demonstrates production migration patterns | Custom stage more code than lightweight-only |
| Favorites unchanged across versions | Future V3 needs another staged migration |

## Alternatives Considered

### Lightweight migration only

Rejected for V1→V2: non-optional new fields on existing rows failed in-place migration during development.

### Delete store on upgrade

Rejected: data loss unacceptable; poor portfolio signal.

### Core Data manual mapping model

Rejected: SwiftData is the chosen persistence technology.

## Verification

1. Install build with V1 schema, create articles
2. Upgrade to V2 build — app launches, articles preserved with sync defaults
3. `ShowcaseMigrationPlanTests` validates in-memory container creation
