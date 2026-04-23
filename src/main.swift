import AppKit
import CoreBluetooth

let serviceUUID = CBUUID(string: "6a521c59-55b5-4384-85c0-6534e63fb09e")
let setPointUUID = CBUUID(string: "6a521c60-55b5-4384-85c0-6534e63fb09e")
let boilerCurrentUUID = CBUUID(string: "6a521c61-55b5-4384-85c0-6534e63fb09e")
let boilerTargetUUID = CBUUID(string: "6a521c66-55b5-4384-85c0-6534e63fb09e")
let ghTempUUID = CBUUID(string: "6A521C62-55B5-4384-85C0-6534E63FB09E")

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)

class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem?
  var centralManager: CBCentralManager!
  var connectedPeripheral: CBPeripheral?

  var isConnected = false
  var setPoint: Double = 0
  var boilerCurrent: Double = 0
  var boilerTarget: Double = 0
  var groupheadTemp: Double = 0
  var waterStatus: String = "OK"

  var menu: NSMenu!
  var statusMenuItem: NSMenuItem!
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

    menu = NSMenu()

    // statusMenuItem = NSMenuItem(title: "Status: Off", action: nil, keyEquivalent: "")
    // menu.addItem(statusMenuItem)
    
    // menu.addItem(NSMenuItem.separator())
    
    currentTempMenuItem = NSMenuItem(title: "Current: --", action: nil, keyEquivalent: "")
    menu.addItem(currentTempMenuItem)
    
    targetTempMenuItem = NSMenuItem(title: "Target: --", action: nil, keyEquivalent: "")
    menu.addItem(targetTempMenuItem)
    
    groupheadTempMenuItem = NSMenuItem(title: "Grouphead: --", action: nil, keyEquivalent: "")
    menu.addItem(groupheadTempMenuItem)
    
    waterStatusMenuItem = NSMenuItem(title: "Water: --", action: nil, keyEquivalent: "")
    menu.addItem(waterStatusMenuItem)

    menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

    statusItem!.menu = menu
    updateStatusBar()
    centralManager = CBCentralManager(delegate: self, queue: .main)
  }

  func updateStatusBar() {
    guard let button = statusItem?.button else { return }

    if !isConnected {
      button.title = "Off"
    } else {
      let isAtTemp = abs(boilerCurrent - boilerTarget) < 0.5
      if isAtTemp {
        button.title = "Ready"
      } else {
        button.title = String(format: "%.1f°C", boilerCurrent)
      }
    }
    
    // statusMenuItem.title = isConnected ? "Status: Connected" : "Status: Off"
    currentTempMenuItem.title = String(format: "Current: %.1f°C", boilerCurrent)
    targetTempMenuItem.title = String(format: "Target: %.1f°C", boilerTarget)
    groupheadTempMenuItem.title = String(format: "Gh: %.1f°C", groupheadTemp)
    waterStatusMenuItem.title = "Water: \(waterStatus)"
  }
}

extension AppDelegate: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: [serviceUUID], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.lowercased().starts(with: "argos") == true {
            central.stopScan()
            connectedPeripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        updateStatusBar()
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension AppDelegate: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([setPointUUID, boilerCurrentUUID, boilerTargetUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, data.count >= 8 else { return }
        
        let temperature = data.withUnsafeBytes { $0.load(as: Double.self) }
        
        switch characteristic.uuid {
        case setPointUUID:
            setPoint = temperature
        case boilerCurrentUUID:
            boilerCurrent = temperature
        case boilerTargetUUID:
            boilerTarget = temperature
        case ghTempUUID:
          groupheadTemp = temperature
        default:
            break
        }
        
        updateStatusBar()
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