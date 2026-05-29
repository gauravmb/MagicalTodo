<!--
SYNC IMPACT REPORT
==================
Version change: N/A (initial authoring) → 1.0.0
Modified principles: N/A (first version)
Added sections:
  - Core Principles (5 principles defined)
  - iOS Platform Standards
  - Development Workflow
  - Governance
Templates requiring updates:
  - .specify/templates/plan-template.md  ✅ updated (iOS-specific context tokens verified)
  - .specify/templates/spec-template.md  ✅ verified (no iOS-incompatible constraints)
  - .specify/templates/tasks-template.md ✅ verified (mobile path conventions present)
Follow-up TODOs:
  - None — all placeholders resolved.
-->

# iOS TODO App Constitution

## Core Principles

### I. SwiftUI-First UI Layer (NON-NEGOTIABLE)
All user interface MUST be built exclusively with SwiftUI. UIKit MUST NOT be introduced
unless a required system capability is provably unavailable in SwiftUI (e.g., a specific
UIKit-only delegate). Any UIKit bridging MUST be isolated in a dedicated `UIKitBridge/`
directory, clearly documented, and reviewed before merge.

**Rationale**: SwiftUI is Apple's strategic UI framework and delivers declarative, reactive
UI with native support for Swift 6 concurrency, previews, and accessibility. Keeping the
UI layer pure SwiftUI reduces cognitive overhead, ensures forward compatibility, and
maximises development velocity on a solo/small team.

### II. Clean Architecture with MVVM (NON-NEGOTIABLE)
The codebase MUST follow Clean Architecture organized into three layers:

- **Presentation** — SwiftUI `View` + `@Observable` ViewModel (`ViewModel/`)
- **Domain** — Pure Swift use-case structs/classes (`UseCases/`) and entity models
  (`Models/`); MUST have zero framework imports (no SwiftUI, no SwiftData)
- **Data** — Repository implementations (`Repositories/`) backed by SwiftData

Each layer MUST only depend on the layer below it (Presentation → Domain ← Data).
Cross-layer direct dependencies are a blocking violation requiring justification in the
Complexity Tracking section of every plan.

**Rationale**: Separating concerns ensures the domain logic is testable in isolation,
platform-agnostic, and survives future migrations (e.g., adding a server sync layer).

### III. SwiftData as the Sole Persistence Layer
All persistent state MUST be stored through SwiftData `@Model` classes. `UserDefaults`
MUST only be used for lightweight, non-relational user preferences (e.g., sort order
preference). Core Data MUST NOT be introduced. Any future iCloud sync MUST be implemented
via SwiftData's CloudKit integration, not a custom sync engine.

**Rationale**: SwiftData is the modern, type-safe successor to Core Data, ships with
iOS 17+, and integrates natively with SwiftUI via the `@Query` macro. Constraining to a
single persistence mechanism eliminates dual-stack complexity.

### IV. Swift 6 Strict Concurrency (NON-NEGOTIABLE)
All asynchronous work MUST use Swift Structured Concurrency (`async`/`await`, `Task`,
`TaskGroup`). The project MUST compile with `SWIFT_STRICT_CONCURRENCY = complete`. All
`@Model` and `@Observable` types MUST be `@MainActor`-isolated unless explicitly proven
safe for concurrent access. Completion-handler callbacks and DispatchQueue-based
concurrency are FORBIDDEN in new code.

**Rationale**: Swift 6 strict concurrency eliminates data races at compile time, a
critical property for a data-driven app where tasks can be created, updated, and deleted
concurrently from background sources in future iterations.

### V. Offline-First, Static Data (No Network Layer)
The app MUST function entirely offline. There MUST be no networking code, URLSession
calls, or third-party networking libraries in v1. All data MUST originate from user input
persisted via SwiftData. If a networking capability is added in a future version, it MUST
be gated behind a protocol-based abstraction (`TodoRepository` protocol) so the Domain
layer remains network-agnostic.

**Rationale**: This is an explicitly static TODO app. Offline-first provides instantaneous
responsiveness, requires no API keys or backend infrastructure, and keeps the initial
scope tight and testable.

## iOS Platform Standards

- **Minimum Deployment Target**: iOS 17.0 (required for SwiftData and `@Observable`).
- **Swift Version**: Swift 6.0 or later; strict concurrency mode ENABLED.
- **Xcode Version**: Xcode 16.0 or later (required for Swift 6 toolchain).
- **Device Support**: iPhone only for v1; iPad adaptive layout is a v2 consideration.
- **Accessibility**: All interactive elements MUST have `.accessibilityLabel` and
  `.accessibilityHint` where applicable. Dynamic Type MUST be supported by using
  system fonts or scaled custom fonts.
- **Dark Mode**: The app MUST support both Light and Dark appearances using semantic
  colors (`Color(.label)`, `Color(.systemBackground)`) — no hard-coded hex values in UI.
- **Localization**: All user-facing strings MUST be externalized via `String(localized:)`
  or `LocalizedStringKey`. The base locale is `en`.
- **Testing Framework**: XCTest for unit tests; Swift Testing framework (`@Test`) MAY be
  used as an alternative for new test files. UI tests MUST use XCUITest.

## Development Workflow

- **Branch Strategy**: Feature branches named `###-short-description` from `main`.
  Direct commits to `main` are FORBIDDEN; all changes require a Pull Request.
- **Commit Discipline**: Commits MUST be atomic and descriptive. Format:
  `type(scope): summary` — e.g., `feat(tasks): add swipe-to-delete gesture`.
- **Code Review Gate**: Every PR MUST pass:
  1. SwiftLint with zero violations (configuration at `.swiftlint.yml`).
  2. All unit tests green.
  3. Peer review (or self-review checklist for solo development).
- **Preview-Driven Development**: Every SwiftUI `View` MUST include at least one
  `#Preview` macro block with representative mock data.
- **No Third-Party Dependencies (v1)**: Swift Package Manager MUST be used if
  dependencies are ever added. v1 MUST ship with zero external dependencies beyond
  the Apple SDK. Any exception requires explicit constitution amendment.

## Governance

This constitution supersedes all other conventions, style guides, or individual
preferences documented elsewhere in the project. Amendments follow this process:

1. **Propose**: Open a PR updating this file with a clear rationale section.
2. **Version**: Increment `CONSTITUTION_VERSION` per semantic versioning rules
   (see below).
3. **Propagate**: Update any dependent templates (`plan-template.md`,
   `spec-template.md`, `tasks-template.md`) in the same PR.
4. **Ratify**: Merge only after at minimum one approving review (or documented
   self-approval with justification for solo projects).

**Versioning Policy**:
- MAJOR — Principle removed, renamed, or fundamentally redefined.
- MINOR — New principle or mandatory section added; scope materially expanded.
- PATCH — Wording clarification, typo fix, non-semantic refinement.

All plans MUST include a "Constitution Check" gate verifying compliance before
Phase 0 research begins. Any deliberate violation MUST be documented in the
Complexity Tracking table of the relevant `plan.md` with a justification and
simpler alternative considered.

**Version**: 1.0.0 | **Ratified**: 2026-05-29 | **Last Amended**: 2026-05-29
