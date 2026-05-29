// TaskFormViewModel.swift
// Presentation layer — @Observable ViewModel shared by AddTaskView and EditTaskView.
// @MainActor ensures all UI state mutations happen on the main thread.

import Foundation
import Observation

/// Shared ViewModel for the Add Task and Edit Task forms.
/// Handles field state, validation, and save/update operations.
@MainActor
@Observable
final class TaskFormViewModel {
    // MARK: - Form Fields
    var title: String = ""
    var note: String = ""
    var priority: Priority = .none

    // MARK: - Validation State
    var titleError: String?

    var isSaveEnabled: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var noteCharacterCount: Int { note.count }
    var showNoteCharacterCount: Bool { note.count > 900 }

    // MARK: - Use Cases
    private let addTaskUseCase: AddTaskUseCase?
    private let editTaskUseCase: EditTaskUseCase?

    // MARK: - Initialisers

    /// Initialiser for Add flow.
    init(addTaskUseCase: AddTaskUseCase) {
        self.addTaskUseCase = addTaskUseCase
        self.editTaskUseCase = nil
    }

    /// Initialiser for Edit flow — pre-fills fields from existing task.
    init(task: Task, editTaskUseCase: EditTaskUseCase) {
        self.addTaskUseCase = nil
        self.editTaskUseCase = editTaskUseCase
        self.title = task.title
        self.note = task.note ?? ""
        self.priority = task.priority
    }

    // MARK: - Actions

    /// Saves a new task. For use in AddTaskView.
    /// - Returns: The created `Task`.
    @discardableResult
    func saveNewTask() async throws -> Task {
        guard let useCase = addTaskUseCase else {
            preconditionFailure("saveNewTask() called on an Edit-configured TaskFormViewModel")
        }
        titleError = nil
        do {
            return try await useCase.execute(
                title: title,
                note: note.isEmpty ? nil : note,
                priority: priority
            )
        } catch let error as TaskValidationError {
            titleError = error.localizedDescription
            throw error
        }
    }

    /// Updates an existing task. For use in EditTaskView.
    /// - Parameter task: The task to update.
    @discardableResult
    func updateTask(_ task: Task) async throws -> Task {
        guard let useCase = editTaskUseCase else {
            preconditionFailure("updateTask() called on an Add-configured TaskFormViewModel")
        }
        titleError = nil
        do {
            return try await useCase.execute(
                task: task,
                newTitle: title,
                newNote: note.isEmpty ? nil : note,
                newPriority: priority
            )
        } catch let error as TaskValidationError {
            titleError = error.localizedDescription
            throw error
        }
    }
}
