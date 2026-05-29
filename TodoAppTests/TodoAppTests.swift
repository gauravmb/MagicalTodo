// TodoAppTests.swift
// Unit test target placeholder.
// Tests for Domain UseCases and Data Repositories go here.

import XCTest

@testable import TodoApp

final class TodoAppTests: XCTestCase {

    // MARK: - AddTaskUseCase Tests

    func testAddTask_withValidTitle_succeedsAndReturnsTask() async throws {
        let repository = MockTaskRepository()
        let useCase = AddTaskUseCase(repository: repository)

        let task = try await useCase.execute(title: "Buy groceries", note: nil)

        XCTAssertEqual(task.title, "Buy groceries")
        XCTAssertFalse(task.isCompleted)
        XCTAssertEqual(task.priority, .none)
        XCTAssertEqual(repository.addedTasks.count, 1)
    }

    func testAddTask_withEmptyTitle_throwsEmptyTitleError() async {
        let repository = MockTaskRepository()
        let useCase = AddTaskUseCase(repository: repository)

        do {
            _ = try await useCase.execute(title: "   ", note: nil)
            XCTFail("Expected emptyTitle error")
        } catch TaskValidationError.emptyTitle {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAddTask_withTitleOver200Chars_throwsTitleTooLong() async {
        let repository = MockTaskRepository()
        let useCase = AddTaskUseCase(repository: repository)
        let longTitle = String(repeating: "a", count: 201)

        do {
            _ = try await useCase.execute(title: longTitle, note: nil)
            XCTFail("Expected titleTooLong error")
        } catch TaskValidationError.titleTooLong {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - CompleteTaskUseCase Tests

    func testCompleteTask_togglesCompletionState() async throws {
        let repository = MockTaskRepository()
        let useCase = CompleteTaskUseCase(repository: repository)
        let task = Task(title: "Test task")

        let completed = try await useCase.execute(task: task)

        XCTAssertTrue(completed.isCompleted)
        XCTAssertNotNil(completed.completedAt)
    }

    func testCompleteTask_revertsWhenAlreadyComplete() async throws {
        let repository = MockTaskRepository()
        let useCase = CompleteTaskUseCase(repository: repository)
        let task = Task(title: "Test task", isCompleted: true)

        let reverted = try await useCase.execute(task: task)

        XCTAssertFalse(reverted.isCompleted)
        XCTAssertNil(reverted.completedAt)
    }

    // MARK: - Priority Tests

    func testPriorityOrdering() {
        XCTAssertTrue(Priority.high > Priority.medium)
        XCTAssertTrue(Priority.medium > Priority.low)
        XCTAssertTrue(Priority.low > Priority.none)
    }
}

// MARK: - Mock Repository

final class MockTaskRepository: TaskRepository {
    var tasks: [Task] = []
    var addedTasks: [Task] = []
    var updatedTasks: [Task] = []
    var deletedTasks: [Task] = []

    func fetchAll() async throws -> [Task] { tasks }

    func add(_ task: Task) async throws {
        tasks.append(task)
        addedTasks.append(task)
    }

    func update(_ task: Task) async throws {
        tasks = tasks.map { $0.id == task.id ? task : $0 }
        updatedTasks.append(task)
    }

    func delete(_ task: Task) async throws {
        tasks.removeAll { $0.id == task.id }
        deletedTasks.append(task)
    }
}
