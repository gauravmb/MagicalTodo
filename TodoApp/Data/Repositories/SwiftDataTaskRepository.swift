// SwiftDataTaskRepository.swift
// Data layer — concrete implementation of TaskRepository using SwiftData.
// This is the ONLY place where ModelContext is used directly.
// The Domain layer only ever sees the TaskRepository protocol.

import Foundation
import SwiftData

/// Concrete repository implementation backed by SwiftData.
/// Marked @MainActor because ModelContext is MainActor-bound by default.
@MainActor
final class SwiftDataTaskRepository: TaskRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    // MARK: - TaskRepository

    func fetchAll() async throws -> [Task] {
        let descriptor = FetchDescriptor<TaskDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = try context.fetch(descriptor)
        return models.map { $0.toDomain() }
    }

    func add(_ task: Task) async throws {
        let model = TaskDataModel.from(task)
        context.insert(model)
        try context.save()
    }

    func update(_ task: Task) async throws {
        let id = task.id
        let descriptor = FetchDescriptor<TaskDataModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else {
            throw RepositoryError.notFound(id: task.id)
        }
        model.update(from: task)
        try context.save()
    }

    func delete(_ task: Task) async throws {
        let id = task.id
        let descriptor = FetchDescriptor<TaskDataModel>(
            predicate: #Predicate { $0.id == id }
        )
        guard let model = try context.fetch(descriptor).first else {
            throw RepositoryError.notFound(id: task.id)
        }
        context.delete(model)
        try context.save()
    }
}

// MARK: - Errors

enum RepositoryError: LocalizedError {
    case notFound(id: UUID)

    var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return String(localized: "Task not found: \(id.uuidString)", bundle: .main)
        }
    }
}
