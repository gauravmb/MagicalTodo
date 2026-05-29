// AddTaskUseCase.swift
// Domain layer — NO framework imports beyond Foundation.

import Foundation

/// Encapsulates the business logic for creating a new task.
struct AddTaskUseCase {
    var repository: any TaskRepository

    /// Creates and persists a new task.
    /// - Parameters:
    ///   - title: The task title. Must be non-empty and ≤ 200 characters.
    ///   - note: Optional note. Must be ≤ 1,000 characters if provided.
    ///   - priority: The task priority. Defaults to `.none`.
    /// - Returns: The newly created `Task`.
    /// - Throws: `TaskValidationError` if validation fails.
    @discardableResult
    func execute(title: String, note: String?, priority: Priority = .none) async throws -> Task {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { throw TaskValidationError.emptyTitle }
        guard trimmedTitle.count <= 200 else { throw TaskValidationError.titleTooLong }
        if let note, note.count > 1_000 { throw TaskValidationError.noteTooLong }

        let task = Task(
            title: trimmedTitle,
            note: note.flatMap { $0.isEmpty ? nil : $0 },
            priority: priority
        )
        try await repository.add(task)
        return task
    }
}
