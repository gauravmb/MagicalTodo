# UI Contracts: Static TODO List App (iOS Native)

**Feature**: `001-static-todo-app`
**Date**: 2026-05-29

This document defines the screen-level contracts — the inputs, outputs, and state
transitions each screen must honour. These are the UI equivalents of API contracts
and guide both implementation and XCUITest scenarios.

---

## Screen 1: Task List (`TaskListView`)

### Purpose
The root screen. Displays all tasks, supports sorting, completion toggling,
deletion, and navigation to add/edit screens.

### Inputs (from ViewModel / SwiftData)
| Signal | Type | Description |
|--------|------|-------------|
| `tasks` | `[Task]` | Ordered list of tasks from store |
| `sortMode` | `SortMode` | `.byDate` or `.byPriority` |
| `isEmpty` | `Bool` | `true` when `tasks.count == 0` |

### Outputs (user actions → ViewModel)
| Action | Trigger | Effect |
|--------|---------|--------|
| `addTask` | Tap "+" button | Present `AddTaskView` as sheet |
| `toggleComplete(task)` | Tap completion circle | Calls `CompleteTaskUseCase` |
| `deleteTask(task)` | Swipe-to-delete | Calls `DeleteTaskUseCase` |
| `selectTask(task)` | Tap task row | Navigate to `EditTaskView` |
| `toggleSortMode` | Tap sort button | Toggles `sortMode` between `.byDate` and `.byPriority` |

### State Variants
| State | Displayed UI |
|-------|-------------|
| Empty list | `ContentUnavailableView` with icon + "No Tasks" + "Tap + to add your first task" |
| Active tasks only | Full list, no section divider |
| Mixed active + completed | Two sections: "Active" and "Completed" |
| Sort by priority active | Tasks ordered High → Medium → Low → None within active section |

### Accessibility
- "+" button: `.accessibilityLabel("Add task")`
- Sort button: `.accessibilityLabel("Sort by \(currentSortMode.displayName)")`
- Task row completion button: `.accessibilityLabel("\(task.title), \(task.isCompleted ? "completed" : "active")")` + `.accessibilityHint("Double-tap to \(task.isCompleted ? "mark active" : "mark complete")")`

---

## Screen 2: Add Task (`AddTaskView`)

### Purpose
Modal sheet for creating a new task.

### Inputs (initial state)
All fields start empty. Priority defaults to `.none`.

### Form Fields
| Field | Control | Validation |
|-------|---------|------------|
| Title | `TextField` | Required; 1–200 chars; trimmed |
| Note | `TextEditor` | Optional; 0–1,000 chars |
| Priority | `Picker` (segmented or menu) | Default: None |

### Outputs (user actions → ViewModel)
| Action | Trigger | Precondition | Effect |
|--------|---------|-------------|--------|
| `saveTask` | Tap "Save" | Title not empty, lengths valid | Calls `AddTaskUseCase`; dismiss sheet |
| `cancel` | Tap "Cancel" | — | Dismiss sheet without saving |

### Validation Behaviour
- "Save" button MUST be disabled when title is empty (after trimming).
- Inline error label below title field appears if user attempts save with empty title.
- Character count shown below note field when note length > 900 chars.

### Accessibility
- Title field: `.accessibilityLabel("Task title")`
- Note field: `.accessibilityLabel("Task note, optional")`
- Priority picker: `.accessibilityLabel("Priority")`
- Save button: `.accessibilityLabel("Save task")`

---

## Screen 3: Edit Task (`EditTaskView`)

### Purpose
Full-screen or sheet view for editing an existing task.

### Inputs (pre-filled from selected `Task`)
| Field | Pre-filled value |
|-------|-----------------|
| Title | `task.title` |
| Note | `task.note ?? ""` |
| Priority | `task.priority` |

### Outputs (user actions → ViewModel)
| Action | Trigger | Precondition | Effect |
|--------|---------|-------------|--------|
| `updateTask` | Tap "Save" | Title not empty, lengths valid | Calls `EditTaskUseCase`; dismiss |
| `cancel` | Tap "Cancel" | — | Dismiss without saving |

### Validation Behaviour
Same rules as Add Task view.

### Accessibility
Same labels as Add Task view. Title field should announce current value on focus.

---

## ViewModel Contracts

### `TaskListViewModel`

```swift
@Observable
final class TaskListViewModel {
    var sortMode: SortMode = .byDate

    // Use cases injected via initialiser
    func toggleComplete(_ task: Task) async
    func delete(_ task: Task) async
}

enum SortMode { case byDate, byPriority }
```

### `TaskFormViewModel`

```swift
@Observable
final class TaskFormViewModel {
    var title: String = ""
    var note: String = ""
    var priority: Priority = .none

    var isSaveEnabled: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }
    var titleError: String? { … }
    var noteCharacterCount: Int { note.count }

    func save() async throws -> Task   // for AddTaskView
    func update(_ task: Task) async throws  // for EditTaskView
}
```

---

## Navigation Map

```
[TaskListView]
      │
      ├─ (tap "+") ──► [AddTaskView] (sheet)
      │                     └─ save/cancel ──► [TaskListView]
      │
      └─ (tap task row) ──► [EditTaskView] (sheet or push)
                                  └─ save/cancel ──► [TaskListView]
```
