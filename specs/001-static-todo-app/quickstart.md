# Quickstart: Static TODO List App (iOS Native)

**Feature**: `001-static-todo-app`
**Date**: 2026-05-29

---

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Xcode | 16.0+ | [developer.apple.com/xcode](https://developer.apple.com/xcode) |
| iOS Simulator | iOS 17.0+ | Bundled with Xcode |
| Swift | 6.0+ | Bundled with Xcode 16 |
| SwiftLint | Latest | `brew install swiftlint` |

No third-party dependencies — no `Package.swift` additions required for v1.

---

## Project Setup

### 1. Create the Xcode Project

```
Xcode → File → New → Project
Template: iOS → App
Product Name: TodoApp
Team: [your team]
Bundle Identifier: com.yourname.TodoApp
Interface: SwiftUI
Language: Swift
Storage: None   ← SwiftData is added manually
```

Enable Swift 6 strict concurrency:

```
Target → Build Settings → SWIFT_STRICT_CONCURRENCY = complete
```

### 2. Enable SwiftData

SwiftData is part of the Apple SDK — no package import needed.
Add `import SwiftData` where required.

### 3. Create Folder Structure

Inside the `TodoApp/` group in Xcode, create groups matching:

```
TodoApp/
├── App/
├── Presentation/
│   ├── Views/
│   └── ViewModels/
├── Domain/
│   ├── Models/
│   ├── Repositories/
│   └── UseCases/
└── Data/
    ├── Models/
    └── Repositories/
```

### 4. Add SwiftLint

```bash
brew install swiftlint
```

Create `.swiftlint.yml` at project root with:

```yaml
excluded:
  - .build
  - .specify
  - specs
opt_in_rules:
  - array_init
  - closure_spacing
  - empty_count
  - explicit_init
  - first_where
disabled_rules:
  - trailing_whitespace
```

Add a Run Script phase to the target:

```bash
if which swiftlint > /dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed"
fi
```

---

## Running the App

```bash
# Open in Xcode
open TodoApp.xcodeproj

# Build & Run (⌘R) on:
# Simulator: iPhone 15 (iOS 17.0+)
# Device: Any iPhone running iOS 17.0+
```

---

## Running Tests

```bash
# Unit tests (⌘U in Xcode, or via xcodebuild)
xcodebuild test \
  -scheme TodoApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'

# UI tests
xcodebuild test \
  -scheme TodoApp \
  -testPlan UITests \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
```

---

## Validation Checklist (User Story 1 — MVP Smoke Test)

Run this checklist manually after the P1 implementation phase is complete:

- [ ] Launch app → empty state view is visible with add prompt
- [ ] Tap "+" → Add Task sheet appears
- [ ] Enter title "Buy groceries" → tap Save → task appears in list
- [ ] Tap completion circle → task is visually marked complete
- [ ] Swipe left → Delete → task is removed
- [ ] Add 3 tasks → force-quit app → relaunch → all 3 tasks visible with correct states
- [ ] Add task with empty title → Save button is disabled or error shown
- [ ] Test in Dark Mode (Settings → Display & Brightness → Dark) → all colours readable
- [ ] Test with VoiceOver enabled (Settings → Accessibility → VoiceOver) → all controls reachable

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `App/TodoApp.swift` | App entry point; `ModelContainer` setup |
| `Domain/Models/Task.swift` | Pure Swift `Task` entity |
| `Domain/Models/Priority.swift` | `Priority` enum |
| `Domain/Repositories/TaskRepository.swift` | Repository protocol |
| `Domain/UseCases/AddTaskUseCase.swift` | Add task business logic |
| `Domain/UseCases/CompleteTaskUseCase.swift` | Toggle completion logic |
| `Domain/UseCases/DeleteTaskUseCase.swift` | Delete logic |
| `Domain/UseCases/EditTaskUseCase.swift` | Edit logic |
| `Data/Models/TaskDataModel.swift` | SwiftData `@Model` |
| `Data/Repositories/SwiftDataTaskRepository.swift` | Repository implementation |
| `Presentation/ViewModels/TaskListViewModel.swift` | `@Observable` list VM |
| `Presentation/Views/TaskListView.swift` | Main list screen |
