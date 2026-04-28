import SwiftUI
import AppKit
import Combine

@main
struct ArgosMateApp: App {
    @StateObject private var machine = ArgosMachine()
    @StateObject private var appState = AppState()
    @StateObject private var notificationAdapter: NotificationAdapter

    init() {
        let machine = ArgosMachine()
        let appState = AppState()
        _machine = StateObject(wrappedValue: machine)
        _appState = StateObject(wrappedValue: appState)
        _notificationAdapter = StateObject(wrappedValue: NotificationAdapter(machine: machine, appState: appState))
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(machine: machine)
                .environmentObject(appState)
        } label: {
            MenuBarLabel(machine: machine)
                .environmentObject(appState)
        }

        Settings {
            SettingsView()
                .frame(width: 400, height: 300)
                .environmentObject(machine)
                .environmentObject(appState)
        }
    }
}
