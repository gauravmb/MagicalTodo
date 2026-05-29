// ContentView.swift
// Root navigation shell. Hosts TaskListView inside a NavigationStack.
// Replaced from placeholder once TaskListView is implemented (T023).

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TaskListView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TaskDataModel.self, inMemory: true)
}
