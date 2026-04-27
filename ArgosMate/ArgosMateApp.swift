import SwiftUI
import AppKit
import Combine

@main
struct ArgosMateApp: App {
    @StateObject private var machine = ArgosMachine()
    @StateObject private var notificationAdapter: NotificationAdapter

    init() {
        let machine = ArgosMachine()
        _machine = StateObject(wrappedValue: machine)
        _notificationAdapter = StateObject(wrappedValue: NotificationAdapter(machine: machine))
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(machine: machine)
        } label: {
            MenuBarLabel(machine: machine)
        }

        Settings {
            SettingsView()
                .frame(width: 400, height: 300)
                .environmentObject(machine)
        }
    }
}
