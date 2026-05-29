---
description: "Task list for Static TODO List App (iOS Native)"
---

# Tasks: Static TODO List App (iOS Native)

**Input**: Design documents from `specs/001-static-todo-app/`

**Prerequisites**: plan.md ✅ | spec.md ✅ | research.md ✅ | data-model.md ✅ | contracts/ui-contracts.md ✅ | quickstart.md ✅

**Tests**: Not explicitly requested — test tasks omitted from user story phases.

**Organization**: Tasks grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3)
- Exact file paths included in every task description

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Create the Xcode project and configure the development environment.
No user story work can begin until this phase is complete.

- [x] T001 Create Xcode project: iOS App template, Product Name `TodoApp`, Interface SwiftUI, Language Swift, Storage None — save at repo root
- [x] T002 Set `SWIFT_STRICT_CONCURRENCY = complete` in `TodoApp` target Build Settings
- [x] T003 Create folder groups in Xcode mirroring Clean Architecture layers: `App/`, `Presentation/Views/`, `Presentation/ViewModels/`, `Domain/Models/`, `Domain/Repositories/`, `Domain/UseCases/`, `Data/Models/`, `Data/Repositories/`
- [x] T004 [P] Add SwiftLint: `brew install swiftlint`; create `.swiftlint.yml` at repo root with excluded paths (`.build`, `.specify`, `specs`) and opt-in rules (`array_init`, `closure_spacing`, `empty_count`, `first_where`)
- [x] T005 [P] Add SwiftLint Run Script Build Phase to `TodoApp` target (warn if not installed, run `swiftlint` if installed)
- [x] T006 [P] Create `TodoAppTests` and `TodoAppUITests` test targets if not auto-created; confirm they compile against `TodoApp` module

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that all user stories depend on. MUST be complete before any US implementation begins.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [x] T007 Create `Domain/Models/Priority.swift` — pure Swift `Priority` enum with cases `.none`, `.low`, `.medium`, `.high`; `Int` raw values 0–3; `Comparable` conformance; `CaseIterable`; `var displayName: String` using `String(localized:)` for each case
- [x] T008 Create `Domain/Models/Task.swift` — pure Swift `Task` struct (no framework imports) with fields: `id: UUID`, `title: String`, `note: String?`, `priority: Priority`, `isCompleted: Bool`, `createdAt: Date`, `completedAt: Date?`; member-wise initializer with defaults (`id = UUID()`, `priority = .none`, `isCompleted = false`, `createdAt = .now`, `completedAt = nil`)
- [x] T009 Create `Domain/Repositories/TaskRepository.swift` — Swift protocol (no framework imports) declaring: `func fetchAll() async throws -> [Task]`; `func add(_ task: Task) async throws`; `func update(_ task: Task) async throws`; `func delete(_ task: Task) async throws`
- [x] T010 Create `Data/Models/TaskDataModel.swift` — SwiftData `@Model final class TaskDataModel` with fields mirroring `Task` entity; `priority` stored as `priorityRawValue: Int`; `init(...)` with same defaults; add `toDomain() -> Task` mapping method and `static func from(_ task: Task) -> TaskDataModel` factory
- [x] T011 Create `Data/Repositories/SwiftDataTaskRepository.swift` — `final class SwiftDataTaskRepository: TaskRepository`; inject `ModelContext` via init; implement all four protocol methods using SwiftData `FetchDescriptor`; map between `TaskDataModel` and `Task` via the methods defined in T010; mark class `@MainActor`
- [x] T012 Create `App/TodoApp.swift` — `@main struct TodoApp: App`; attach `.modelContainer(for: TaskDataModel.self)` to `WindowGroup`; set `ContentView()` as root
- [x] T013 Create `App/ContentView.swift` — `struct ContentView: View` wrapping a `NavigationStack`; placeholder `Text("Task List")` body (replaced in US1)

**Checkpoint**: Build succeeds with zero SwiftLint violations; all types compile under `SWIFT_STRICT_CONCURRENCY = complete`.

---

## Phase 3: User Story 1 — Create & Manage Tasks (Priority: P1) 🎯 MVP

**Goal**: Users can add tasks, mark them complete, delete them, and see all data persisted across app restarts.

**Independent Test**: Launch app → empty state visible → add "Buy groceries" → appears in list → mark complete → strikethrough visible → swipe-delete a second task → force-quit → relaunch → state preserved. (See `quickstart.md` MVP smoke test.)

### Implementation for User Story 1

- [x] T014 [P] [US1] Create `Domain/UseCases/AddTaskUseCase.swift` — struct with `var repository: any TaskRepository`; `func execute(title: String, note: String?) async throws -> Task`; validate title non-empty (trim whitespace, throw `TaskValidationError.emptyTitle` if blank) and ≤ 200 chars; validate note ≤ 1,000 chars if non-nil; create `Task` value and call `repository.add(_:)`
- [x] T015 [P] [US1] Create `Domain/UseCases/CompleteTaskUseCase.swift` — struct with `var repository: any TaskRepository`; `func execute(task: Task) async throws -> Task`; toggle `isCompleted`; set `completedAt = .now` when completing, `nil` when reverting; call `repository.update(_:)`; return updated `Task`
- [x] T016 [P] [US1] Create `Domain/UseCases/DeleteTaskUseCase.swift` — struct with `var repository: any TaskRepository`; `func execute(task: Task) async throws`; call `repository.delete(_:)`
- [x] T017 [P] [US1] Create `Domain/UseCases/FetchTasksUseCase.swift` — struct with `var repository: any TaskRepository`; `func execute() async throws -> [Task]`; call `repository.fetchAll()` and return result
- [x] T018 [US1] Create `TaskValidationError.swift` in `Domain/UseCases/` — Swift `enum TaskValidationError: LocalizedError` with cases `emptyTitle`, `titleTooLong`, `noteTooLong`; implement `var errorDescription: String?` for each using `String(localized:)`
- [x] T019 [US1] Create `Presentation/ViewModels/TaskListViewModel.swift` — `@MainActor @Observable final class TaskListViewModel`; inject `AddTaskUseCase`, `CompleteTaskUseCase`, `DeleteTaskUseCase`; expose `func toggleComplete(_ task: Task) async`; `func delete(_ task: Task) async`; `var sortMode: SortMode = .byDate`; define `enum SortMode { case byDate, byPriority }`
- [x] T020 [US1] Create `Presentation/ViewModels/TaskFormViewModel.swift` — `@MainActor @Observable final class TaskFormViewModel`; inject `AddTaskUseCase`; `var title = ""`; `var note = ""`; `var priority: Priority = .none`; `var isSaveEnabled: Bool` (title non-empty after trim); `var titleError: String?`; `var noteCharacterCount: Int`; `func saveNewTask() async throws -> Task`
- [x] T021 [US1] Create `Presentation/Views/TaskRowView.swift` — `struct TaskRowView: View` accepting a `Task` binding and completion/delete callbacks; show title with strikethrough when `isCompleted`; show priority badge (coloured dot or label); show completion circle toggle button; `.accessibilityLabel` and `.accessibilityHint` per ui-contracts.md
- [x] T022 [US1] Create `Presentation/Views/AddTaskView.swift` — `struct AddTaskView: View`; `@State` owned `TaskFormViewModel`; title `TextField` with inline error label; note `TextEditor` with character count overlay (visible when >900); `Picker` for priority (segmented); Save button disabled when `!viewModel.isSaveEnabled`; Cancel and Save toolbar buttons; dismiss on success
- [x] T023 [US1] Update `App/ContentView.swift` — replace placeholder with `TaskListView()` as the NavigationStack root
- [x] T024 [US1] Create `Presentation/Views/TaskListView.swift` — `struct TaskListView: View`; `@Query` fetching `TaskDataModel` list sorted by `createdAt` descending; inject `ModelContext` via `@Environment`; instantiate `TaskListViewModel` with `SwiftDataTaskRepository`; render `TaskRowView` rows; `.swipeActions` for delete; `ContentUnavailableView` when list empty; toolbar "+" button presenting `AddTaskView` as sheet; toolbar sort toggle button

**Checkpoint**: User Story 1 fully functional — add, complete, delete, persist across restarts. Run quickstart.md MVP smoke test. All SwiftLint and Swift 6 concurrency checks pass.

---

## Phase 4: User Story 2 — Organize Tasks with Priorities (Priority: P2)

**Goal**: Users can assign High / Medium / Low priority to tasks and sort the list by priority.

**Independent Test**: Add three tasks with High, Low, and no priority respectively → tap Sort by Priority → verify order is High → Low → None. Removing this feature does not affect User Story 1.

### Implementation for User Story 2

- [x] T025 [P] [US2] Update `Presentation/ViewModels/TaskFormViewModel.swift` — confirm `var priority: Priority = .none` already present (from T020); add `func updateTask(_ task: Task) async throws` for edit flow (preparation for US3 reuse); verify priority is passed through to `AddTaskUseCase.execute`
- [x] T026 [P] [US2] Update `AddTaskUseCase.swift` — add `priority: Priority` parameter to `execute(title:note:priority:)`; include in constructed `Task` value; update all callers (T022 `AddTaskView`)
- [x] T027 [US2] Update `TaskListViewModel.swift` — implement sort logic: when `sortMode == .byPriority`, sort active tasks by `priority` descending (High first) then `createdAt` descending; expose `var sortedTasks: [Task]` computed property; update `toggleSortMode()` to cycle `.byDate` ↔ `.byPriority`
- [x] T028 [US2] Update `TaskListView.swift` — switch list data source from raw `@Query` array to `viewModel.sortedTasks`; update sort toolbar button label and accessibility label to reflect active sort mode (`.accessibilityLabel("Sort by \(sortMode.displayName)")`); show priority badge in `TaskRowView` (badge already rendered in T021 — verify colour mapping: High=red, Medium=orange, Low=blue, None=clear)
- [x] T029 [US2] Update `AddTaskView.swift` — verify priority `Picker` is wired to `viewModel.priority` and passes through on save; add accessibility label to picker per ui-contracts.md

**Checkpoint**: User Stories 1 AND 2 independently functional. Priority sort works; P1 add/complete/delete unaffected.

---

## Phase 5: User Story 3 — Edit Task Details (Priority: P3)

**Goal**: Users can tap an existing task to open an edit view and update its title, note, or priority.

**Independent Test**: Add task "Old title" → tap row → change title to "New title" → save → list shows "New title". Tap same row → tap Cancel → list unchanged.

### Implementation for User Story 3

- [x] T030 [P] [US3] Create `Domain/UseCases/EditTaskUseCase.swift` — struct with `var repository: any TaskRepository`; `func execute(task: Task, newTitle: String, newNote: String?, newPriority: Priority) async throws -> Task`; apply same validation as `AddTaskUseCase` (reuse `TaskValidationError`); construct updated `Task` value preserving `id`, `createdAt`, `isCompleted`, `completedAt`; call `repository.update(_:)`; return updated task
- [x] T031 [P] [US3] Update `TaskFormViewModel.swift` — add `func updateTask(_ task: Task) async throws` calling `EditTaskUseCase.execute`; add `init(for task: Task, editUseCase: EditTaskUseCase)` convenience initializer pre-filling `title`, `note`, `priority` from existing task
- [x] T032 [US3] Create `Presentation/Views/EditTaskView.swift` — `struct EditTaskView: View`; accept `task: Task` and dismiss callback; instantiate `TaskFormViewModel(for: task, editUseCase:)`; same field layout as `AddTaskView` (title, note, priority picker); Save calls `viewModel.updateTask`; Cancel dismisses without saving; same validation UX and accessibility labels
- [x] T033 [US3] Update `TaskListView.swift` — wire task row tap to present `EditTaskView` as sheet (`.sheet(item: $selectedTask)`); add `@State var selectedTask: Task?`; on dismiss, refresh list if needed (SwiftData `@Query` handles reactivity automatically)
- [x] T034 [US3] Inject `EditTaskUseCase` into `TaskListViewModel` — add stored property and pass through to `EditTaskView` on presentation

**Checkpoint**: All three user stories independently functional. Edit, save, and cancel all work correctly. SwiftData persists edits across restarts.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect all user stories — accessibility, Dark Mode, localisation hardening, and code quality.

- [x] T035 [P] Audit all user-facing strings in `Views/` and `ViewModels/` — replace any string literals with `String(localized: "key")` or `LocalizedStringKey`; create/update `Localizable.strings` with `en` base locale entries
- [x] T036 [P] Accessibility audit: open app in Simulator with Accessibility Inspector; verify all interactive controls (`TaskRowView` circle, "+" button, sort button, Save/Cancel buttons) have descriptive `.accessibilityLabel` and `.accessibilityHint` per ui-contracts.md; fix any gaps
- [x] T037 [P] Dark Mode verification: run app in Simulator with Dark appearance; confirm all text, backgrounds, and badges use only semantic colors (`Color(.label)`, `Color(.systemBackground)`, `Color(.systemGroupedBackground)`); replace any hard-coded colors
- [x] T038 [P] Run SwiftLint clean pass: `swiftlint` from repo root; resolve all warnings and errors; update `.swiftlint.yml` if needed
- [x] T039 Run quickstart.md full validation checklist: all 9 smoke-test items must pass on iPhone 15 Simulator (iOS 17.0); document any failures
- [x] T040 [P] Code review pass: verify Domain layer files (`Task.swift`, `Priority.swift`, `TaskRepository.swift`, all UseCases) contain zero framework imports (`import Foundation` allowed); add `// No framework imports beyond Foundation` comment to each Domain file header
- [x] T041 [P] Update `specs/001-static-todo-app/quickstart.md` — add any corrections discovered during implementation; confirm all commands and file paths are accurate

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion — BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Phase 2 completion — MVP deliverable
- **User Story 2 (Phase 4)**: Depends on Phase 2; can start after Phase 3 (priority enum already defined in T007)
- **User Story 3 (Phase 5)**: Depends on Phase 2 and Phase 4 (`TaskFormViewModel` from T025 reused)
- **Polish (Phase 6)**: Depends on Phases 3–5 completion

### User Story Dependencies

- **US1 (P1)**: Depends only on Foundational (Phase 2). No dependency on US2 or US3.
- **US2 (P2)**: Depends on Foundational (Phase 2). Extends US1 sort/priority display — can be developed in parallel after Phase 2 but integrates into `TaskListView`.
- **US3 (P3)**: Depends on Foundational (Phase 2) + `TaskFormViewModel` introduced in US1 (T020) and extended in US2 (T025).

### Within Each User Story

- Domain layer (Use Cases, Models) before Data layer before Presentation layer
- ViewModels before Views that consume them
- Row/cell views before list views that embed them

### Parallel Opportunities

Tasks marked `[P]` within a phase can run simultaneously:

- **Phase 2**: T007–T011 can all run in parallel (different files)
- **Phase 3**: T014–T018 (all use cases + error type) can run in parallel
- **Phase 6**: T035–T038, T040–T041 all fully parallelisable

---

## Parallel Example: Phase 2 (Foundational)

```bash
# These 5 tasks have no cross-dependencies — launch all together:
Task T007: Create Domain/Models/Priority.swift
Task T008: Create Domain/Models/Task.swift
Task T009: Create Domain/Repositories/TaskRepository.swift
Task T010: Create Data/Models/TaskDataModel.swift
Task T011: Create Data/Repositories/SwiftDataTaskRepository.swift

# Then sequentially:
Task T012: Create App/TodoApp.swift (needs TaskDataModel from T010)
Task T013: Create App/ContentView.swift (needs TodoApp.swift from T012)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Run quickstart.md smoke test
5. Demo / ship MVP if ready

### Incremental Delivery

1. Phase 1 + 2 → Foundation ready
2. Phase 3 → US1 complete → **MVP demo** (add, complete, delete, persist)
3. Phase 4 → US2 complete → **Priority + sort demo**
4. Phase 5 → US3 complete → **Edit flow demo**
5. Phase 6 → Polish → **Release candidate**

### Parallel Team Strategy

With multiple developers, after Phase 2 completes:

- **Developer A**: Phase 3 (US1 — core flow)
- **Developer B**: Can start Phase 4 Domain tasks (T025–T026) in parallel since they only touch Domain files

---

## Notes

- `[P]` tasks = different files, no dependencies on incomplete tasks in same phase
- `[US#]` label maps each task to a specific user story for traceability
- Each user story is independently completable and testable
- SwiftData `@Query` provides automatic reactivity — no manual list refresh needed
- `TaskFormViewModel` is shared between Add and Edit flows to avoid duplication
- Avoid: vague tasks, same-file conflicts, cross-story dependencies that break story independence
- Commit after each task or logical group (use `/speckit-git-commit` after each phase)
