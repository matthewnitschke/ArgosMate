import AppKit

let app = NSApplication.shared
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

if let button = statusItem.button {
    if let iconURL = Bundle.main.url(forResource: "icon", withExtension: "svg"),
       let iconImage = NSImage(contentsOf: iconURL) {
        button.image = iconImage
    } else {
        button.image = NSImage(systemSymbolName: "ant", accessibilityDescription: "ArgosMate")
    }
}

let menu = NSMenu()
menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
statusItem.menu = menu

app.run()