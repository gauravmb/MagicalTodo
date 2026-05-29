// TaskValidationError.swift
// Domain layer — validation errors for task use cases.
// No framework imports beyond Foundation.

import Foundation

/// Errors thrown when task input fails domain validation rules.
enum TaskValidationError: LocalizedError {
    /// The task title was empty or whitespace-only.
    case emptyTitle
    /// The task title exceeds 200 characters.
    case titleTooLong
    /// The task note exceeds 1,000 characters.
    case noteTooLong

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return String(localized: "Title is required.", bundle: .main)

        case .titleTooLong:
            return String(localized: "Title must be 200 characters or fewer.", bundle: .main)

        case .noteTooLong:
            return String(localized: "Note must be 1,000 characters or fewer.", bundle: .main)
        }
    }
}
