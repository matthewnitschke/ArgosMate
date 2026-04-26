import SwiftUI

struct MenuBarLabel: View {
    @ObservedObject var machine: ArgosMachine


    var body: some View {
        Image(nsImage: createIconImage())
        
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
                    machine.boilerCurrent,
                    machine.boilerTarget
                ))
            }
        }
    }
}
