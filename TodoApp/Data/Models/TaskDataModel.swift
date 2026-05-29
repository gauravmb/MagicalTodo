// TaskDataModel.swift
// Data layer — SwiftData @Model class.
// This is the ONLY file in the project that imports SwiftData.
// Domain entities (Task) are mapped to/from this model in the
// repository layer — Domain code never touches TaskDataModel directly.

import Foundation
import SwiftData

/// SwiftData persistence model for a to-do task.
/// Priority is stored as an Int rawValue because SwiftData does not
/// yet natively support custom enum types with full migration fidelity.
@Model
final class TaskDataModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var note: String?
    var priorityRawValue: Int
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?

    init(
        id: UUID = UUID(),
        title: String,
        note: String? = nil,
        priorityRawValue: Int = 0,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.priorityRawValue = priorityRawValue
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
    }

    // MARK: - Domain Mapping

    /// Maps this persistence model to a pure Domain Task value.
    func toDomain() -> Task {
        Task(
            id: id,
            title: title,
            note: note,
            priority: Priority(rawValue: priorityRawValue) ?? .none,
            isCompleted: isCompleted,
            createdAt: createdAt,
            completedAt: completedAt
        )
    }

    /// Creates a new TaskDataModel from a Domain Task value.
    static func from(_ task: Task) -> TaskDataModel {
        TaskDataModel(
            id: task.id,
            title: task.title,
            note: task.note,
            priorityRawValue: task.priority.rawValue,
            isCompleted: task.isCompleted,
            createdAt: task.createdAt,
            completedAt: task.completedAt
        )
    }

    /// Updates this model's mutable fields from a Domain Task value.
    /// Used by the update operation to avoid creating a new @Model object.
    func update(from task: Task) {
        title = task.title
        note = task.note
        priorityRawValue = task.priority.rawValue
        isCompleted = task.isCompleted
        completedAt = task.completedAt
    }
}
