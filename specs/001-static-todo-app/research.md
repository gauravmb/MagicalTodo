# Research: Static TODO List App (iOS Native)

**Feature**: `001-static-todo-app`
**Branch**: `001-static-todo-app`
**Date**: 2026-05-29

---

## R-001: Architecture Pattern

**Decision**: Clean Architecture with MVVM (ViewModel via `@Observable`)

**Rationale**: Clean Architecture enforces strict separation between Presentation,
Domain, and Data layers. The Domain layer remains framework-agnostic and unit-testable
in isolation. `@Observable` (introduced in iOS 17) replaces `ObservableObject` /
`@Published` with a simpler, more performant macro-based model that integrates
natively with SwiftUI's dependency tracking. This is the idiomatic choice for iOS 17+
and aligns directly with Constitution Principle II.

**Alternatives considered**:
- MVC: Too tightly coupled for testability; rejected.
- TCA (The Composable Architecture): Powerful but heavyweight for a simple app; adds
  third-party dependency which violates Constitution Principle V.
- VIPER: Over-engineered for a solo/small team and a single-feature app; rejected.

---

## R-002: Persistence Layer

**Decision**: SwiftData with `@Model` classes and `@Query` in SwiftUI views

**Rationale**: SwiftData (iOS 17+) is Apple's modern persistence framework built on
top of Core Data's proven storage engine but with a Swift-native, macro-driven API.
`@Model` classes declare persistence intent with zero boilerplate. `@Query` in
SwiftUI views provides reactive data binding — any store change automatically
re-renders the view. CloudKit integration is available out of the box for v2 iCloud
sync without architectural changes. Aligns with Constitution Principle III.

**Key implementation details**:
- `ModelContainer` created once at app entry point and injected via `.modelContainer()`
- `ModelContext` accessed via `@Environment(\.modelContext)` in views or passed to
  repositories
- All SwiftData `@Model` classes live in `Data/Models/`; they are NOT reused directly
  in the Domain layer — they are mapped to/from pure Domain entities

**Alternatives considered**:
- Core Data: Verbose, Obj-C-heritage API; SwiftData is its direct successor; rejected.
- SQLite (via GRDB): No third-party dependencies allowed in v1; rejected.
- File-based JSON: Error-prone, no query support, poor performance at scale; rejected.
- UserDefaults: Not suitable for structured list data; rejected (only for preferences).

---

## R-003: Concurrency Model

**Decision**: Swift 6 Structured Concurrency (`async`/`await`, `@MainActor`)

**Rationale**: Swift 6 with `SWIFT_STRICT_CONCURRENCY = complete` detects data races
at compile time. For a UI-bound app, most operations run on `@MainActor`. SwiftData
`ModelContext` is `@MainActor`-bound by default, so no explicit actor-hopping is
required for basic CRUD. Async use-case methods allow future background I/O (e.g.,
export, import) to integrate cleanly without refactoring. Aligns with Constitution
Principle IV.

**Alternatives considered**:
- DispatchQueue / GCD: Legacy, not type-safe for concurrency; forbidden by constitution.
- Combine: Superseded by Swift Concurrency for async flows; adds complexity without
  benefit for this use case.

---

## R-004: UI Framework

**Decision**: SwiftUI with declarative list composition (`List`, `NavigationStack`)

**Rationale**: SwiftUI is Apple's primary UI framework and the mandated choice per
Constitution Principle I. For a list-based app, `List` with `@Query`-driven data
provides automatic diffing, swipe actions (`.swipeActions`), and accessibility
support out of the box. `NavigationStack` (iOS 16+) handles push navigation for the
edit view. No UIKit bridging is required.

**Key SwiftUI patterns used**:
- `@Query` for reactive task list from SwiftData
- `.swipeActions` for swipe-to-delete
- `sheet` / `navigationDestination` for add/edit flow
- `ContentUnavailableView` (iOS 17+) for empty state
- `.listRowBackground` + semantic colors for Dark Mode
- `.accessibilityLabel` / `.accessibilityHint` for VoiceOver

**Alternatives considered**:
- UIKit `UITableView`: Rejected per constitution. SwiftUI List is fully capable.
- UIKit + SwiftUI bridging (`UIViewControllerRepresentable`): No identified need.

---

## R-005: Xcode Project Structure

**Decision**: Single Xcode project, no Swift Package Manager local packages for v1

**Rationale**: The app is a single-target iOS application. A monolithic Xcode project
with folders reflecting the Clean Architecture layers (Presentation/, Domain/, Data/)
provides full transparency without the overhead of multi-package management. The
Domain layer's isolation is enforced by convention and constitution, not by compiler
boundaries. Compiler boundaries via local Swift packages are a valid v2 improvement if
the team scales.

**Directory layout decided**:
```
TodoApp/
├── App/
│   ├── TodoApp.swift          # @main entry point, ModelContainer setup
│   └── ContentView.swift      # Root navigation view
├── Presentation/
│   ├── Views/
│   │   ├── TaskListView.swift
│   │   ├── TaskRowView.swift
│   │   ├── AddTaskView.swift
│   │   └── EditTaskView.swift
│   └── ViewModels/
│       ├── TaskListViewModel.swift
│       └── TaskFormViewModel.swift
├── Domain/
│   ├── Models/
│   │   └── Task.swift         # Pure Swift entity (no framework imports)
│   ├── Repositories/
│   │   └── TaskRepository.swift  # Protocol
│   └── UseCases/
│       ├── AddTaskUseCase.swift
│       ├── CompleteTaskUseCase.swift
│       ├── DeleteTaskUseCase.swift
│       ├── EditTaskUseCase.swift
│       └── FetchTasksUseCase.swift
└── Data/
    ├── Models/
    │   └── TaskDataModel.swift  # SwiftData @Model
    └── Repositories/
        └── SwiftDataTaskRepository.swift  # Conforms to TaskRepository protocol
TodoAppTests/
TodoAppUITests/
```

---

## R-006: Testing Strategy

**Decision**: XCTest for Domain/Use-Case unit tests; XCUITest for critical UI flows

**Rationale**: Domain use cases are pure Swift functions with no framework dependencies —
they are trivially unit-testable with XCTest and in-memory mock repositories. SwiftData
supports in-memory `ModelContainer` configurations for Data layer tests without disk I/O.
XCUITest covers the P1 user story end-to-end (add, complete, delete, relaunch).

**Test structure**:
- `TodoAppTests/Domain/` — Use case unit tests using mock `TaskRepository`
- `TodoAppTests/Data/` — Repository tests using in-memory SwiftData container
- `TodoAppUITests/` — XCUITest for User Story 1 acceptance scenarios

---

## R-007: Minimum Deployment Target & Toolchain

**Decision**: iOS 17.0, Swift 6.0, Xcode 16.0

**Rationale**:
- iOS 17.0 is required for SwiftData and `@Observable` — both are non-negotiable per
  the constitution.
- Swift 6.0 enables strict concurrency checking.
- Xcode 16.0 ships the Swift 6 toolchain and full SwiftData IDE support.
- As of 2026, iOS 17+ adoption exceeds 90% of active iPhone users.

---

## R-008: Accessibility & Localization

**Decision**: Semantic colors + Dynamic Type + `String(localized:)` throughout

**Rationale**: Constitution mandates accessibility and localization readiness. Using
system semantic colors (`Color(.label)`, `Color(.systemBackground)`) provides automatic
Dark Mode adaptation with zero extra code. Dynamic Type is supported automatically for
system fonts; custom fonts MUST use `Font.custom(_:size:relativeTo:)`. All user-facing
strings use `String(localized:)` with keys to enable future locale addition.

---

## Summary: All NEEDS CLARIFICATION Items Resolved

| ID | Question | Resolution |
|----|----------|------------|
| R-001 | Architecture pattern | Clean Architecture + MVVM with `@Observable` |
| R-002 | Persistence | SwiftData `@Model` + `@Query` |
| R-003 | Concurrency | Swift 6 `async/await`, `@MainActor` |
| R-004 | UI Framework | SwiftUI (List, NavigationStack, ContentUnavailableView) |
| R-005 | Project structure | Single Xcode target, folder-based layer separation |
| R-006 | Testing | XCTest (unit) + XCUITest (UI) |
| R-007 | Toolchain | iOS 17+, Swift 6, Xcode 16 |
| R-008 | A11y & i18n | Semantic colors, Dynamic Type, `String(localized:)` |
