import SwiftUI
import AppKit
import Combine

@main
struct ArgosMateApp: App {
    @StateObject private var machine: ArgosMachine

    init() {
        let useMock = CommandLine.arguments.contains("--mock")
        
        _machine = StateObject(wrappedValue: ArgosMachine(
            adapter: useMock ? MockBluetoothAdapter() : CoreBluetoothAdapter()
        ))
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(machine: machine)
                .task {
                    machine.initiate()
                }
        } label: {
            MenuBarLabel()
        }
    }
}
