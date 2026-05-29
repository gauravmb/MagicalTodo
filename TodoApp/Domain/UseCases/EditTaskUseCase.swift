// EditTaskUseCase.swift
// Domain layer — NO framework imports beyond Foundation.

import Foundation

/// Encapsulates the business logic for updating an existing task's content.
struct EditTaskUseCase {
    var repository: any TaskRepository

    /// Updates the mutable fields of an existing task.
    /// - Parameters:
    ///   - task: The task to update (matched by `id`).
    ///   - newTitle: New title. Must be non-empty and ≤ 200 characters.
    ///   - newNote: New note. Must be ≤ 1,000 characters if provided.
    ///   - newPriority: New priority level.
    /// - Returns: The updated `Task`.
    @discardableResult
    func execute(task: Task, newTitle: String, newNote: String?, newPriority: Priority) async throws -> Task {
        let trimmedTitle = newTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { throw TaskValidationError.emptyTitle }
        guard trimmedTitle.count <= 200 else { throw TaskValidationError.titleTooLong }
        if let newNote, newNote.count > 1_000 { throw TaskValidationError.noteTooLong }

        var updated = task
        updated.title = trimmedTitle
        updated.note = newNote.flatMap { $0.isEmpty ? nil : $0 }
        updated.priority = newPriority
        // isCompleted and completedAt are not modified by edit
        try await repository.update(updated)
        return updated
    }
}
