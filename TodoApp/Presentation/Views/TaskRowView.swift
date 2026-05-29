// TaskRowView.swift
// Presentation layer — single task row cell for TaskListView.

import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onToggleComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Completion circle
            Button(action: onToggleComplete) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .animation(.easeInOut(duration: 0.2), value: task.isCompleted)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                task.isCompleted
                    ? String(localized: "\(task.title), completed")
                    : String(localized: "\(task.title), active")
            )
            .accessibilityHint(
                task.isCompleted
                    ? String(localized: "Double-tap to mark active")
                    : String(localized: "Double-tap to mark complete")
            )

            // Task content
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                    .lineLimit(2)

                if let note = task.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Priority badge
            if task.priority != .none {
                PriorityBadge(priority: task.priority)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Priority Badge

private struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        Text(priority.shortLabel)
            .font(.caption2.bold())
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
            .accessibilityLabel(priority.displayName)
    }

    private var badgeColor: Color {
        switch priority {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .blue
        case .none:   return .clear
        }
    }
}

#Preview {
    List {
        TaskRowView(
            task: Task(title: "Buy groceries", note: "Milk, eggs, bread", priority: .high),
            onToggleComplete: {}
        )
        TaskRowView(
            task: Task(title: "Call dentist", priority: .medium, isCompleted: true),
            onToggleComplete: {}
        )
        TaskRowView(
            task: Task(title: "Read a book"),
            onToggleComplete: {}
        )
    }
}
