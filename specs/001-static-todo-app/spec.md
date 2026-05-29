# Feature Specification: Static TODO List App (iOS Native)

**Feature Branch**: `001-static-todo-app`

**Created**: 2026-05-29

**Status**: Draft

**Input**: User description: "its a static TODO List App for IOS Native, use the best architecture and latest technology"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create and Manage Tasks (Priority: P1)

A user opens the app for the first time and wants to capture things they need to do. They
can add new tasks by typing a title and optionally a brief note. Tasks immediately appear
in a list. The user can mark any task as complete with a single tap, and completed tasks
are visually distinguished from active ones. The user can delete tasks they no longer need
via a swipe gesture.

**Why this priority**: This is the core value proposition of the app. Without the ability
to add, complete, and remove tasks, the app delivers zero value.

**Independent Test**: The story is fully testable by launching the app on a device or
simulator, adding three tasks, marking one as done, deleting another, and verifying the
list reflects all changes correctly after the app is relaunched (persistence check).

**Acceptance Scenarios**:

1. **Given** the app is open with an empty list, **When** the user taps the "Add" button
   and types a task title, **Then** the new task appears at the top of the active task
   list immediately.
2. **Given** the task list has at least one active task, **When** the user taps the
   completion indicator on a task, **Then** the task is visually marked as complete
   (e.g., strikethrough, checkmark) and moves to or is grouped under the completed section.
3. **Given** the task list has at least one task, **When** the user swipes left on a task
   and taps "Delete", **Then** the task is permanently removed from the list.
4. **Given** the user has added tasks, **When** the app is closed and reopened, **Then**
   all tasks (with their completion state) appear exactly as left.

---

### User Story 2 - Organize Tasks with Priorities (Priority: P2)

A user wants to distinguish between urgent and non-urgent tasks. They can assign a
priority level (High, Medium, Low) to any task when creating or editing it. The task list
can be sorted by priority so the most important items surface to the top.

**Why this priority**: Priority management significantly improves the utility of a TODO
app and is a natural P2 feature — valuable but the app is usable without it.

**Independent Test**: The story is testable by adding tasks with different priority
levels, toggling the sort-by-priority option, and verifying tasks reorder accordingly.
Removing this feature would not break User Story 1.

**Acceptance Scenarios**:

1. **Given** the user is adding or editing a task, **When** they select a priority
   (High / Medium / Low), **Then** the task is saved with that priority and a visual
   indicator (e.g., coloured badge) is shown on the task cell.
2. **Given** the task list contains tasks with mixed priorities, **When** the user
   activates "Sort by Priority", **Then** High-priority tasks appear before Medium,
   which appear before Low.
3. **Given** a task exists without an assigned priority, **Then** it is treated as
   "No Priority" and sorts after Low-priority tasks.

---

### User Story 3 - Edit Task Details (Priority: P3)

A user realises a task title or note needs updating. They can tap an existing task to open
an edit view where they can modify the title, note, and priority. Changes are saved when
they dismiss the view, and the updated task is reflected immediately in the list.

**Why this priority**: Editing is a natural complement to creation, but the app is still
useful if tasks must be deleted and re-added. It is therefore a polish feature.

**Independent Test**: Add a task, tap to edit, change the title and note, dismiss the
view, and confirm the list shows the updated information.

**Acceptance Scenarios**:

1. **Given** the task list contains a task, **When** the user taps the task row, **Then**
   an edit view opens pre-filled with the task's current title, note, and priority.
2. **Given** the edit view is open, **When** the user modifies the title and taps
   "Save" (or dismisses), **Then** the task list shows the updated title.
3. **Given** the edit view is open, **When** the user taps "Cancel", **Then** no changes
   are saved and the task remains unchanged.

---

### Edge Cases

- What happens when the user submits an empty task title? The system MUST prevent saving
  and display an inline validation message ("Title is required").
- What happens when a task title exceeds 200 characters? The input field MUST cap entry
  at 200 characters.
- What happens when a note exceeds 1,000 characters? The note field MUST cap at 1,000
  characters.
- How does the list behave with 0 tasks? An empty-state illustration and prompt
  ("Tap + to add your first task") MUST be displayed.
- What happens if the device runs out of storage? The system MUST surface a user-friendly
  error ("Unable to save. Your device storage may be full.") and not silently discard data.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST allow users to create a new task with a title (required) and
  an optional note.
- **FR-002**: The app MUST prevent saving a task with a blank title and display an
  inline error.
- **FR-003**: The app MUST display all tasks in a scrollable list, grouped or visually
  separated by completion status (active vs. completed).
- **FR-004**: Users MUST be able to mark any task as complete or revert it to active with
  a single interaction.
- **FR-005**: Users MUST be able to permanently delete a task via a swipe gesture.
- **FR-006**: All task data (title, note, priority, completion state) MUST be persisted
  locally and survive app termination and device restarts.
- **FR-007**: Users MUST be able to assign one of three priority levels (High, Medium,
  Low) to any task; unassigned tasks default to "No Priority".
- **FR-008**: The task list MUST support sorting by priority (High → Medium → Low →
  None) toggled by user action.
- **FR-009**: Users MUST be able to edit the title, note, and priority of an existing
  task.
- **FR-010**: The app MUST display an empty-state view when no tasks exist.
- **FR-011**: The app MUST support both Light and Dark appearance modes without any
  user configuration (automatic system-driven).
- **FR-012**: All interactive elements MUST be accessible via VoiceOver with descriptive
  labels.

### Key Entities

- **Task**: The central entity. Attributes: unique identifier, title (string, required,
  max 200 chars), note (string, optional, max 1,000 chars), priority (enum: High / Medium
  / Low / None), completion state (boolean), creation date, completion date (optional).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can add a new task in under 10 seconds from app launch on a
  supported device.
- **SC-002**: All tasks created in a session are visible and in the correct state
  immediately after the app is relaunched (zero data loss under normal conditions).
- **SC-003**: The task list renders up to 500 tasks without perceptible lag (smooth
  scroll at 60 fps on a device 3 or more years old).
- **SC-004**: Completion and deletion interactions provide visible feedback within
  300 ms of the user's tap.
- **SC-005**: 100% of interactive controls are reachable and operable using VoiceOver
  navigation alone.
- **SC-006**: The app passes Apple's accessibility audit with zero critical violations.

## Assumptions

- The app targets a single user on a single device; multi-user or account-based sync is
  out of scope for v1.
- iCloud sync (cross-device) is out of scope for v1 but must not be architecturally
  precluded.
- The minimum supported iOS version is iOS 17.0.
- Notifications and reminders are out of scope for v1.
- Sub-tasks, tags, and due dates are out of scope for v1.
- No onboarding flow is required; the empty-state view is sufficient for first-time users.
- The app will ship in English only for v1; the codebase must use localizable strings
  throughout to support future locales.
