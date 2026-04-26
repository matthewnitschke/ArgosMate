import SwiftUI
import AppKit
import Combine

@main
struct ArgosMateApp: App {
    @StateObject private var machine = ArgosMachine()
    
    init() {
        machine.initiate()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(machine: machine)
        } label: {
            MenuBarLabel(machine: machine)
        }
    }
}
