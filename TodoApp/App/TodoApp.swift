// TodoApp.swift
// App entry point. ModelContainer is configured here and injected
// into the SwiftUI environment for all descendant views.
// No framework imports beyond SwiftUI and SwiftData — per constitution.

import SwiftData
import SwiftUI

@main
struct TodoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TaskDataModel.self)
    }
}
