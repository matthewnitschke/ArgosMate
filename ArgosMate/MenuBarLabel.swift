import SwiftUI

struct MenuBarLabel: View {
    @ObservedObject var machine: ArgosMachine

//    private var statusText: String {
//        if !machine.isConnected {
//            return ""
//        } else if machine.waterStatus != "OK" {
//            return "No Water"
//        } else {
//            let isAtTemp = abs(machine.boilerCurrent - machine.boilerTarget) < 0.5
//            if isAtTemp {
//                return "Ready"
//            } else {
//                return String(format: "%.0f° / %.0f°", machine.boilerCurrent, machine.boilerTarget)
//            }
//        }
//    }
//
    var body: some View {
        Image(nsImage: createIconImage())
        
        if !machine.isConnected {
            Text("")
        } else if machine.waterStatus != "OK" {
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
//        if statusText.isEmpty && machine.isConnected {
//            Image(systemName: "cup.and.saucer.fill")
//        } else if !machine.isConnected {
//            Image(systemName: "cup.and.saucer")
//        } else {
//            Text(statusText)
//                .font(.system(.body, design: .monospaced))
//        }
    }
}
