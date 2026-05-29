// EditTaskView.swift
// Presentation layer — sheet for editing an existing task.

import SwiftUI

struct EditTaskView: View {
    @Environment(\.dismiss) private var dismiss

    private let task: Task
    @State private var viewModel: TaskFormViewModel

    init(task: Task, repository: any TaskRepository) {
        self.task = task
        let editUseCase = EditTaskUseCase(repository: repository)
        _viewModel = State(initialValue: TaskFormViewModel(task: task, editTaskUseCase: editUseCase))
    }

    var body: some View {
        NavigationStack {
            Form {
                // Title section
                Section {
                    TextField(String(localized: "Task title"), text: $viewModel.title)
                        .accessibilityLabel(String(localized: "Task title"))
                        .submitLabel(.next)

                    if let error = viewModel.titleError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text(String(localized: "Title"))
                } footer: {
                    Text(String(localized: "Required"))
                        .foregroundStyle(viewModel.title.isEmpty ? .red : .secondary)
                }

                // Note section
                Section {
                    ZStack(alignment: .bottomTrailing) {
                        TextEditor(text: $viewModel.note)
                            .frame(minHeight: 80)
                            .accessibilityLabel(String(localized: "Task note, optional"))

                        if viewModel.showNoteCharacterCount {
                            Text("\(viewModel.noteCharacterCount)/1000")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(4)
                        }
                    }
                } header: {
                    Text(String(localized: "Note (optional)"))
                }

                // Priority section
                Section {
                    Picker(String(localized: "Priority"), selection: $viewModel.priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel(String(localized: "Priority"))
                } header: {
                    Text(String(localized: "Priority"))
                }
            }
            .navigationTitle(String(localized: "Edit Task"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        save()
                    }
                    .disabled(!viewModel.isSaveEnabled)
                    .accessibilityLabel(String(localized: "Save task"))
                }
            }
        }
    }

    private func save() {
        _Concurrency.Task {
            do {
                try await viewModel.updateTask(task)
                dismiss()
            } catch {
                // Error surfaced via viewModel.titleError
            }
        }
    }
}
