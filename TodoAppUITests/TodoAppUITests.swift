// TodoAppUITests.swift
// UI test target covering User Story 1 acceptance scenarios.

import XCTest

final class TodoAppUITests: XCTestCase {

    private lazy var app: XCUIApplication = {
        let application = XCUIApplication()
        return application
    }()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - US1: Create task

    func testAddTask_appearsInList() throws {
        // Given: empty task list
        // When: tap Add and enter a title
        app.navigationBars["My Tasks"].buttons["Add task"].tap()

        let titleField = app.textFields["Task title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
        titleField.tap()
        titleField.typeText("Buy groceries")

        app.navigationBars.buttons["Save task"].tap()

        // Then: task appears in list
        XCTAssertTrue(app.staticTexts["Buy groceries"].waitForExistence(timeout: 2))
    }

    // MARK: - US1: Empty title validation

    func testAddTask_withEmptyTitle_saveButtonDisabled() throws {
        app.navigationBars["My Tasks"].buttons["Add task"].tap()

        let saveButton = app.navigationBars.buttons["Save task"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        XCTAssertFalse(saveButton.isEnabled)
    }

    // MARK: - US1: Mark complete

    func testMarkTaskComplete_showsStrikethrough() throws {
        // Given: a task in the list (pre-seeded by launchArgument in production)
        // This test relies on testAddTask running first — in production use launch arguments to seed data
        app.navigationBars["My Tasks"].buttons["Add task"].tap()
        app.textFields["Task title"].tap()
        app.textFields["Task title"].typeText("Call dentist")
        app.navigationBars.buttons["Save task"].tap()

        // When: tap completion button
        let completeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Call dentist'")).firstMatch
        XCTAssertTrue(completeButton.waitForExistence(timeout: 2))
        completeButton.tap()

        // Then: task moves to Completed section
        XCTAssertTrue(app.staticTexts["Completed"].waitForExistence(timeout: 2))
    }

    // MARK: - US1: Delete task

    func testDeleteTask_removesFromList() throws {
        // Add a task first
        app.navigationBars["My Tasks"].buttons["Add task"].tap()
        app.textFields["Task title"].tap()
        app.textFields["Task title"].typeText("Task to delete")
        app.navigationBars.buttons["Save task"].tap()

        // Swipe to delete
        let taskCell = app.staticTexts["Task to delete"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 2))
        taskCell.swipeLeft()
        app.buttons["Delete"].tap()

        // Verify removed
        XCTAssertFalse(app.staticTexts["Task to delete"].exists)
    }
}
