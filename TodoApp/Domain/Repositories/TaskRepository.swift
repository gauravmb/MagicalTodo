// TaskRepository.swift
// Domain layer — NO framework imports beyond Foundation.
// This protocol defines the contract between Domain and Data layers.
// Concrete implementations live in Data/Repositories/.

import Foundation

/// Protocol that any task persistence implementation must conform to.
/// The Domain layer depends only on this abstraction, never on
/// SwiftData or any other concrete persistence technology.
public protocol TaskRepository: Sendable {
    /// Returns all tasks, unsorted. Sorting is the responsibility of callers.
    func fetchAll() async throws -> [Task]

    /// Persists a new task.
    func add(_ task: Task) async throws

    /// Updates an existing task. The task is matched by its `id`.
    func update(_ task: Task) async throws

    /// Permanently removes a task.
    func delete(_ task: Task) async throws
}
