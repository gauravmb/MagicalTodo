// Task.swift
// Domain layer — NO framework imports beyond Foundation.
// No SwiftUI, SwiftData, or other Apple framework imports permitted here.
// Per constitution Principle II: Domain layer is framework-agnostic.

import Foundation

/// The central domain entity representing a single to-do item.
/// This is a pure Swift value type — it has no knowledge of persistence
/// or UI frameworks.
public struct Task: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var note: String?
    public var priority: Priority
    public var isCompleted: Bool
    public let createdAt: Date
    public var completedAt: Date?

    public init(
        id: UUID = UUID(),
        title: String,
        note: String? = nil,
        priority: Priority = .none,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
