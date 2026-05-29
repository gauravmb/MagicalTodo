# TodoApp — Project Steering

## Project Overview

iOS native Todo app built with **SwiftUI + SwiftData**. Targets **iOS 17+, Swift 6**. No third-party dependencies — Apple frameworks only.

## Project Setup

- **Project file**: `project.yml` (XcodeGen) — do not edit `.xcodeproj` directly
- **Bundle ID**: `com.todoapp.TodoApp`
- **Swift**: 6.0, `SWIFT_STRICT_CONCURRENCY: complete`
- **Deployment target**: iOS 17.0
- **Xcode**: 16.0
- **SwiftLint**: runs as a pre-build script via Homebrew (`brew install swiftlint`)

## Architecture

Clean Architecture with strict layer separation:

```
App/                        → Entry point, ModelContainer setup
Domain/                     → Pure Swift, NO framework imports beyond Foundation
  Models/                   → Task (struct), Priority (enum)
  Repositories/             → TaskRepository protocol (abstraction only)
  UseCases/                 → AddTaskUseCase, EditTaskUseCase, CompleteTaskUseCase,
                              DeleteTaskUseCase, FetchTasksUseCase, TaskValidationError
Data/                       → SwiftData implementation
  Models/                   → TaskDataModel (@Model class)
  Repositories/             → SwiftDataTaskRepository (concrete implementation)
Presentation/               → SwiftUI views and ViewModels
  ViewModels/               → TaskListViewModel, TaskFormViewModel
  Views/                    → TaskListView, TaskRowView, AddTaskView, EditTaskView
Supporting/                 → Assets, Info.plist
TodoAppTests/               → Unit tests (XCTest) — Domain UseCases and Repositories
TodoAppUITests/             → UI tests (XCUITest) — acceptance scenarios per user story
```

## Key Architectural Rules

- **Domain layer is framework-agnostic** — only `Foundation` imports allowed. No SwiftUI, SwiftData, or other Apple frameworks.
- **SwiftData is isolated to the Data layer** — `TaskDataModel` is the only `@Model` class. `ModelContext` is only used in `SwiftDataTaskRepository`.
- **Domain never touches `TaskDataModel`** — mapping happens in the repository via `toDomain()` and `from(_:)`.
- **ViewModels use `@Observable` + `@MainActor`** — not `ObservableObject`.
- **Repository is injected** into use cases and ViewModels, never instantiated inside Domain code.
- **`_Concurrency.Task {}`** must be used in ViewModels to avoid shadowing the domain `Task` struct.

## Domain Model

### Task (struct)
```swift
id: UUID, title: String, note: String?,
priority: Priority, isCompleted: Bool,
createdAt: Date, completedAt: Date?
```

### Priority (enum)
```swift
case none = 0, low = 1, medium = 2, high = 3
```
Stored as `Int` rawValue in persistence (`priorityRawValue`).

## Validation Rules

Enforced in use cases, thrown as `TaskValidationError`:
- Title: non-empty, max 200 characters (whitespace trimmed)
- Note: max 1,000 characters

## Patterns to Follow

- New use cases go in `Domain/UseCases/` as structs with a single `execute(...)` method
- New views go in `Presentation/Views/`, new ViewModels in `Presentation/ViewModels/`
- Any new persistence model goes in `Data/Models/` and must include `toDomain()` and `from(_:)` mapping
- New repository protocols go in `Domain/Repositories/`, concrete implementations in `Data/Repositories/`
- All user-facing strings use `String(localized:bundle:)` for localization
- Small reusable UI components (like `PriorityBadge`) live as `private struct` inside the view file that owns them
- `_Concurrency.Task {}` must be used in Views and ViewModels to avoid shadowing the domain `Task` struct
- Views receive dependencies (repository) via `init` — never access `ModelContext` directly in ViewModels

## Testing

**Unit tests** (`TodoAppTests/`):
- Use `XCTest` + `@testable import TodoApp`
- Test Domain UseCases and Repository logic
- Use `MockTaskRepository` (already defined in `TodoAppTests.swift`) — conforms to `TaskRepository` protocol, tracks `addedTasks`, `updatedTasks`, `deletedTasks`
- Never import SwiftData in unit tests — use the mock instead

**UI tests** (`TodoAppUITests/`):
- Use `XCUITest`, launch with `app.launchArguments = ["--uitesting"]`
- Cover acceptance scenarios per user story
- Use `accessibilityLabel` values to find elements (set in views)
- `continueAfterFailure = false` is the standard setup

## Code Style

- SwiftLint is configured (`.swiftlint.yml`)
- Line length: warning at 120, error at 150
- File length: warning at 400, error at 600
- Function body: warning at 50 lines, error at 80 lines
- `force_unwrapping` is an opt-in rule — avoid `!` unwraps
- `missing_docs` is enabled — add doc comments to public types and methods

## Spec Kit Integration

This project uses GitHub Spec Kit. Feature specs live in `specs/` directory.
Current active feature: `specs/001-static-todo-app/`
Spec Kit skills are in `.agents/skills/speckit-*/SKILL.md`.
