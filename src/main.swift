import AppKit

let useMock = CommandLine.arguments.contains("--mock")

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)

class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem?
  var machine: ArgosMachine!

  var menu: NSMenu!
  var currentTempMenuItem: NSMenuItem!
  var targetTempMenuItem: NSMenuItem!
  var groupheadTempMenuItem: NSMenuItem!
  var waterStatusMenuItem: NSMenuItem!

  func applicationDidFinishLaunching(_ notification: Notification) {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    if let button = statusItem!.button {
      button.title = ""
      let image = createIconImage()
      image.isTemplate = true
      button.image = image
    }

    if useMock {
      machine = MockArgosMachine()
    } else {
      machine = RealArgosMachine()
    }

    machine.onUpdate = { [weak self] _ in self?.updateStatusBar() }

    buildMenu()
    updateStatusBar()

    machine.initiate()
  }

  func buildMenu() {
    menu = NSMenu()

    if machine.isConnected {
      currentTempMenuItem = NSMenuItem(title: String(format: "Current: %.1f°C", machine.boilerCurrent), action: nil, keyEquivalent: "")
      menu.addItem(currentTempMenuItem)

      targetTempMenuItem = NSMenuItem(title: String(format: "Target: %.1f°C", machine.boilerTarget), action: nil, keyEquivalent: "")
      menu.addItem(targetTempMenuItem)

      groupheadTempMenuItem = NSMenuItem(title: String(format: "Gh: %.1f°C", machine.groupheadTemp), action: nil, keyEquivalent: "")
      menu.addItem(groupheadTempMenuItem)

      waterStatusMenuItem = NSMenuItem(title: "Water: \(machine.waterStatus)", action: nil, keyEquivalent: "")
      menu.addItem(waterStatusMenuItem)
    } else {
      let disconnectedItem = NSMenuItem(title: "Disconnected", action: nil, keyEquivalent: "")
      menu.addItem(disconnectedItem)
    }

    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

    statusItem?.menu = menu
  }

  func updateStatusBar() {
    guard let button = statusItem?.button else { return }

    if !machine.isConnected {
      button.title = ""
    } else if machine.waterStatus != "OK" {
      button.title = "No Water"
    } else {
      let isAtTemp = abs(machine.boilerCurrent - machine.boilerTarget) < 0.5
      button.title = isAtTemp ? "Ready" : "Heating"
    }

    buildMenu()
  }
}

func createIconImage(size: NSSize = NSSize(width: 22, height: 22)) -> NSImage {
    let image = NSImage(size: size)
    image.addRepresentation(NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!)

    image.lockFocus()

    let context = NSGraphicsContext.current!.cgContext

    let scaleX = size.width / 36.0
    let scaleY = size.height / 36.0

    let path = CGMutablePath()
    path.move(to: CGPoint(x: 7 * scaleX, y: (36 - 26.3033) * scaleY))
    path.addLine(to: CGPoint(x: 7 * scaleX, y: (36 - 32) * scaleY))
    path.addLine(to: CGPoint(x: 28 * scaleX, y: (36 - 32) * scaleY))
    path.addLine(to: CGPoint(x: 28 * scaleX, y: (36 - 16.5359) * scaleY))
    path.addLine(to: CGPoint(x: 8.03317 * scaleX, y: (36 - 4) * scaleY))
    path.addLine(to: CGPoint(x: 8.03317 * scaleX, y: (36 - 11.0385) * scaleY))
    path.addLine(to: CGPoint(x: 21.6965 * scaleX, y: (36 - 19.5036) * scaleY))
    path.addLine(to: CGPoint(x: 21.6965 * scaleX, y: (36 - 26.3033) * scaleY))
    path.closeSubpath()

    context.setFillColor(NSColor.black.cgColor)
    context.addPath(path)
    context.fillPath()

    image.unlockFocus()

    return image
}

app.run()