import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var machine: ArgosMachine

    var body: some View {
        if machine.isConnected {
            Text(String(format: "Current: %.1f°C", machine.boilerCurrent))
            Text(String(format: "Target: %.1f°C", machine.boilerTarget))
            Text(String(format: "Grouphead: %.1f°C", machine.groupheadTemp))
            Text("Water: \(machine.waterStatus)")
        } else {
            Text("Disconnected")
        }

        Divider()

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: [])
    }
}
