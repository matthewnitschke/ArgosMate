import SwiftUI

struct MenuBarLabel: View {
    @ObservedObject var machine: ArgosMachine
    @EnvironmentObject var appState: AppState

    var body: some View {
        Image(nsImage: machine.isConnected ? createIconImage() : createOutlineIconImage())
        
        if !machine.isConnected {
            Text("")
        } else if machine.fluidLevel != .ok {
            Text("No Water")
        } else {
            let isAtTemp = abs(machine.boilerCurrent - machine.boilerTarget) < 0.5
            if isAtTemp {
                Text("Ready")
            } else {
                Text(String(
                    format: "%.0f° / %.0f°",
                    appState.convertTemperature(machine.boilerCurrent),
                    appState.convertTemperature(machine.boilerTarget)
                ))
            }
        }
    }
}
