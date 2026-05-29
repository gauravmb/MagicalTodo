// Priority.swift
// Domain layer — NO framework imports beyond Foundation.
// No SwiftUI, SwiftData, or other Apple framework imports permitted here.
// Per constitution Principle II: Domain layer is framework-agnostic.

import Foundation

/// Represents the urgency level of a Task.
/// Stored as Int rawValue in the persistence layer (TaskDataModel).
public enum Priority: Int, CaseIterable, Comparable, Sendable {
    case none   = 0
    case low    = 1
    case medium = 2
    case high   = 3

    public static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// User-facing display name, localised.
    public var displayName: String {
        switch self {
        case .none:   return String(localized: "No Priority", bundle: .main)
        case .low:    return String(localized: "Low", bundle: .main)
        case .medium: return String(localized: "Medium", bundle: .main)
        case .high:   return String(localized: "High", bundle: .main)
        }
    }

    /// Short label for badges.
    public var shortLabel: String {
        switch self {
        case .none:   return ""
        case .low:    return String(localized: "L", bundle: .main)
        case .medium: return String(localized: "M", bundle: .main)
        case .high:   return String(localized: "H", bundle: .main)
        }
    }
}
