import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

if let button = statusItem.button {
    let bundle = Bundle.main
    print("Bundle:", bundle.bundlePath)
    print("EXE:", bundle.executablePath ?? "")

    let exePath = bundle.executablePath ?? ""
    let exeURL = URL(fileURLWithPath: exePath)
    let bundlePath = exeURL.deletingLastPathComponent()
    let resourcesPath = bundlePath.appendingPathComponent("ArgosMate_ArgosMate.bundle")
    let iconPath = resourcesPath.appendingPathComponent("icon.svg").path
    print("Icon path:", iconPath)

    if let image = NSImage(contentsOfFile: iconPath) {
        image.isTemplate = true
        image.size = NSSize(width: 22, height: 22)
        button.image = image
    } else {
        button.image = NSImage(systemSymbolName: "ant", accessibilityDescription: "ArgosMate")
    }
}

let menu = NSMenu()
menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
statusItem.menu = menu

app.run()