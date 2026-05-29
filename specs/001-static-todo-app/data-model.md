# Data Model: Static TODO List App (iOS Native)

**Feature**: `001-static-todo-app`
**Date**: 2026-05-29

---

## Overview

The app has a single core entity: **Task**. It maps to both a pure-Swift Domain model
and a SwiftData persistence model. The two are deliberately separate to keep the Domain
layer framework-agnostic (Constitution Principle II).

---

## Entity: Task

### Domain Model (`Domain/Models/Task.swift`)

Pure Swift struct — zero framework imports.

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `id` | `UUID` | ✅ | System-generated on creation; immutable |
| `title` | `String` | ✅ | 1–200 characters; whitespace-trimmed |
| `note` | `String?` | ❌ | 0–1,000 characters; `nil` if absent |
| `priority` | `Priority` | ✅ | Enum: `.high`, `.medium`, `.low`, `.none`; default `.none` |
| `isCompleted` | `Bool` | ✅ | Default `false` |
| `createdAt` | `Date` | ✅ | Set to `Date.now` at creation; immutable |
| `completedAt` | `Date?` | ❌ | Set when `isCompleted` transitions `false → true`; cleared on revert |

#### Priority Enum

```swift
// Domain/Models/Priority.swift
enum Priority: Int, CaseIterable, Comparable {
    case none   = 0
    case low    = 1
    case medium = 2
    case high   = 3

    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var displayName: String {
        switch self {
        case .none:   return String(localized: "No Priority")
        case .low:    return String(localized: "Low")
        case .medium: return String(localized: "Medium")
        case .high:   return String(localized: "High")
        }
    }
}
```

---

### Persistence Model (`Data/Models/TaskDataModel.swift`)

SwiftData `@Model` class. Fields mirror the Domain entity with the same constraints
enforced at the use-case layer before persistence.

```swift
// Data/Models/TaskDataModel.swift
import SwiftData
import Foundation

@Model
final class TaskDataModel {
    var id: UUID
    var title: String
    var note: String?
    var priorityRawValue: Int   // stores Priority.rawValue
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        note: String? = nil,
        priorityRawValue: Int = 0,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil
    ) { … }
}
```

> **Note**: `Priority` is stored as `Int` (`rawValue`) to keep the `@Model` class free
> of custom enum types, which SwiftData does not yet support natively with full
> migration fidelity. The mapping is performed in the repository layer.

---

### Mapping: Domain ↔ Persistence

The `SwiftDataTaskRepository` handles bidirectional mapping:

```
TaskDataModel → Task   (toDomain())
Task          → TaskDataModel  (fromDomain() / update existing)
```

No Domain code ever imports SwiftData.

---

## Validation Rules

All validation is enforced in Use Cases before any persistence call.

| Rule | Condition | Error |
|------|-----------|-------|
| `title` required | `title.trimmingCharacters(in: .whitespaces).isEmpty` | "Title is required" |
| `title` max length | `title.count > 200` | "Title must be 200 characters or fewer" |
| `note` max length | `(note?.count ?? 0) > 1000` | "Note must be 1,000 characters or fewer" |

---

## State Transitions

```
Task Life Cycle:
  Created (isCompleted: false, completedAt: nil)
       │
       ├─── [User marks complete] ──────► Completed (isCompleted: true, completedAt: Date.now)
       │                                       │
       └─────────────────────────────────────── [User reverts] ──► Active (isCompleted: false, completedAt: nil)
       │
       └─── [User deletes] ──────────────────────────────────────► Deleted (removed from store)
```

---

## Sort Orders

| Sort Mode | Primary Key | Secondary Key | Direction |
|-----------|-------------|---------------|-----------|
| Default (by date) | `createdAt` | — | Newest first |
| By priority | `priority` descending | `createdAt` | High → None, newest first within group |

---

## Relationships

None in v1. The `Task` entity is self-contained. Future versions may introduce:
- `Tag` (many-to-many)
- `Project` or `List` (one-to-many)

---

## ModelContainer Configuration

```swift
// App/TodoApp.swift
@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TaskDataModel.self)
    }
}
```

For unit tests, an in-memory container is used:

```swift
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(for: TaskDataModel.self, configurations: config)
```
