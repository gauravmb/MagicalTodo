// AddTaskView.swift
// Presentation layer — sheet for creating a new task.

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var viewModel: TaskFormViewModel

    init(repository: any TaskRepository) {
        let addUseCase = AddTaskUseCase(repository: repository)
        _viewModel = State(initialValue: TaskFormViewModel(addTaskUseCase: addUseCase))
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
            .navigationTitle(String(localized: "New Task"))
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
                try await viewModel.saveNewTask()
                dismiss()
            } catch {
                // Error is surfaced via viewModel.titleError for display
            }
        }
    }
}
