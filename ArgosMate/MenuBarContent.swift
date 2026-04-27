import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var machine: ArgosMachine

    var body: some View {
        Section("Argos Espresso Machine") {
            Divider()
            if machine.isConnected {
                Button(String(format: "Set Point: %.1f°C", machine.setPoint)) {}
                Button(String(format: "Current: %.1f°C", machine.boilerCurrent)) {}
                Button(String(format: "Target: %.1f°C", machine.boilerTarget)) {}
                Button(String(format: "Grouphead: %.1f°C", machine.groupheadTemp)) {}
            } else {
                Text("Disconnected")
            }
            
            Divider()
            
            SettingsLink {
                Text("Settings")
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [])
        }
    }
}
