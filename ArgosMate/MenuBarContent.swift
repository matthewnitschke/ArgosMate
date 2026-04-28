import SwiftUI

struct MenuBarContent: View {
    @ObservedObject var machine: ArgosMachine
    @EnvironmentObject var appState: AppState

    var body: some View {
        Section("Argos Espresso Machine") {
            Divider()
            if machine.isConnected {
                let unitSymbol = appState.temperatureUnit == .celsius ? "°C" : "°F"
                Button(String(format: "Set Point: %.1f\(unitSymbol)", appState.convertTemperature(machine.setPoint))) {}
                Button(String(format: "Current: %.1f\(unitSymbol)", appState.convertTemperature(machine.boilerCurrent))) {}
                Button(String(format: "Target: %.1f\(unitSymbol)", appState.convertTemperature(machine.boilerTarget))) {}
                Button(String(format: "Grouphead: %.1f\(unitSymbol)", appState.convertTemperature(machine.groupheadTemp))) {}
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
