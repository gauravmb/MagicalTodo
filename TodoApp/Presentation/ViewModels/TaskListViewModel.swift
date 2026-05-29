// TaskListViewModel.swift
// Presentation layer — @Observable ViewModel for TaskListView.
// @MainActor ensures all UI state mutations happen on the main thread.
// NOTE: `_Concurrency.Task {}` is used throughout to avoid shadowing by
// the domain `Task` struct.

import Foundation
import Observation
import SwiftData

/// Sort order options for the task list.
enum SortMode: String, CaseIterable {
    case byDate
    case byPriority

    var displayName: String {
        switch self {
        case .byDate:     return String(localized: "Sort by Date", bundle: .main)
        case .byPriority: return String(localized: "Sort by Priority", bundle: .main)
        }
    }

    var iconName: String {
        switch self {
        case .byDate:     return "clock"
        case .byPriority: return "flag"
        }
    }
}

/// ViewModel for the main task list screen.
/// Owns sort state and dispatches use-case calls for completion and deletion.
/// Context is injected via setContext(_:) after the view appears.
@MainActor
@Observable
final class TaskListViewModel {
    // MARK: - State
    var sortMode: SortMode = .byDate
    var errorMessage: String?

    // MARK: - Private
    private var completeTaskUseCase: CompleteTaskUseCase?
    private var deleteTaskUseCase: DeleteTaskUseCase?

    // MARK: - Context injection (called from .onAppear)

    func setContext(_ context: ModelContext) {
        let repository = SwiftDataTaskRepository(context: context)
        completeTaskUseCase = CompleteTaskUseCase(repository: repository)
        deleteTaskUseCase = DeleteTaskUseCase(repository: repository)
    }

    // MARK: - Actions

    func toggleComplete(_ task: Task) {
        guard let useCase = completeTaskUseCase else { return }
        _Concurrency.Task {
            do {
                try await useCase.execute(task: task)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func delete(_ task: Task) {
        guard let useCase = deleteTaskUseCase else { return }
        _Concurrency.Task {
            do {
                try await useCase.execute(task: task)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func toggleSortMode() {
        sortMode = sortMode == .byDate ? .byPriority : .byDate
    }

    // MARK: - Sorting

    /// Applies the current sort mode to a list of tasks.
    /// Active and completed tasks are always separated — active comes first.
    func sorted(_ tasks: [Task]) -> [Task] {
        let active = tasks.filter { !$0.isCompleted }
        let completed = tasks.filter { $0.isCompleted }

        let sortedActive: [Task]
        switch sortMode {
        case .byDate:
            sortedActive = active.sorted { $0.createdAt > $1.createdAt }

        case .byPriority:
            sortedActive = active.sorted {
                if $0.priority != $1.priority { return $0.priority > $1.priority }
                return $0.createdAt > $1.createdAt
            }
        }

        let sortedCompleted = completed.sorted {
            ($0.completedAt ?? $0.createdAt) > ($1.completedAt ?? $1.createdAt)
        }

        return sortedActive + sortedCompleted
    }
}
