// FetchTasksUseCase.swift
// Domain layer — NO framework imports beyond Foundation.

import Foundation

/// Encapsulates the business logic for retrieving all tasks.
struct FetchTasksUseCase {
    var repository: any TaskRepository

    /// Returns all tasks from the store, unsorted.
    /// Sorting is applied at the ViewModel layer based on user preference.
    func execute() async throws -> [Task] {
        try await repository.fetchAll()
    }
}
