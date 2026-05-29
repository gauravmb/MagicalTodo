// TaskListView.swift
// Presentation layer — main screen of the app.
// Uses @Query for reactive SwiftData access and TaskListViewModel
// for business logic (sort, complete, delete).

import SwiftData
import SwiftUI

struct TaskListView: View {
    @Environment(\.modelContext) private var context

    // SwiftData reactive query — sorted by creation date descending as base.
    // Further sorting (by priority) is handled by the ViewModel.
    @Query(sort: \TaskDataModel.createdAt, order: .reverse)
    private var taskModels: [TaskDataModel]

    @State private var viewModel = TaskListViewModel()
    @State private var showingAddTask = false
    @State private var selectedTask: Task?

    private var tasks: [Task] {
        viewModel.sorted(taskModels.map { $0.toDomain() })
    }

    private var activeTasks: [Task] { tasks.filter { !$0.isCompleted } }
    private var completedTasks: [Task] { tasks.filter { $0.isCompleted } }

    var body: some View {
        Group {
            if tasks.isEmpty {
                emptyStateView
            } else {
                taskListView
            }
        }
        .navigationTitle(String(localized: "My Tasks"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(String(localized: "Add task"))
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.toggleSortMode()
                } label: {
                    Label(
                        viewModel.sortMode.displayName,
                        systemImage: viewModel.sortMode.iconName
                    )
                }
                .accessibilityLabel(
                    String(localized: "Sort by \(viewModel.sortMode == .byDate ? "priority" : "date")")
                )
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(repository: SwiftDataTaskRepository(context: context))
        }
        .sheet(item: $selectedTask) { task in
            EditTaskView(task: task, repository: SwiftDataTaskRepository(context: context))
        }
        .onAppear {
            viewModel.setContext(context)
        }
        .alert(
            String(localized: "Error"),
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(String(localized: "OK")) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        ContentUnavailableView(
            String(localized: "No Tasks"),
            systemImage: "checklist",
            description: Text(String(localized: "Tap + to add your first task"))
        )
    }

    private var taskListView: some View {
        List {
            if !activeTasks.isEmpty {
                Section(String(localized: "Active")) {
                    ForEach(activeTasks) { task in
                        TaskRowView(task: task) {
                            viewModel.toggleComplete(task)
                        }
                        .onTapGesture {
                            selectedTask = task
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.delete(task)
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                        }
                    }
                }
            }

            if !completedTasks.isEmpty {
                Section(String(localized: "Completed")) {
                    ForEach(completedTasks) { task in
                        TaskRowView(task: task) {
                            viewModel.toggleComplete(task)
                        }
                        .onTapGesture {
                            selectedTask = task
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.delete(task)
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: tasks.map(\.id))
    }
}

#Preview {
    NavigationStack {
        TaskListView()
    }
    .modelContainer(for: TaskDataModel.self, inMemory: true)
}
