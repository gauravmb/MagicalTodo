// DeleteTaskUseCase.swift
// Domain layer — NO framework imports beyond Foundation.

import Foundation

/// Encapsulates the business logic for permanently removing a task.
struct DeleteTaskUseCase {
    var repository: any TaskRepository

    /// Permanently deletes a task from the store.
    /// - Parameter task: The task to delete.
    func execute(task: Task) async throws {
        try await repository.delete(task)
    }
}
