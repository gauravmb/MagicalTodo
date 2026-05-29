// CompleteTaskUseCase.swift
// Domain layer — NO framework imports beyond Foundation.

import Foundation

/// Encapsulates the business logic for toggling a task's completion state.
struct CompleteTaskUseCase {
    var repository: any TaskRepository

    /// Toggles the `isCompleted` state of a task.
    /// - Sets `completedAt` to `Date.now` when completing.
    /// - Clears `completedAt` when reverting to active.
    /// - Parameter task: The task to toggle.
    /// - Returns: The updated `Task` with new completion state.
    @discardableResult
    func execute(task: Task) async throws -> Task {
        var updated = task
        updated.isCompleted.toggle()
        updated.completedAt = updated.isCompleted ? .now : nil
        try await repository.update(updated)
        return updated
    }
}
