import AppKit
import CoreBluetooth

let serviceUUID = CBUUID(string: "6a521c59-55b5-4384-85c0-6534e63fb09e")
let setPointUUID = CBUUID(string: "6a521c60-55b5-4384-85c0-6534e63fb09e")
let boilerCurrentUUID = CBUUID(string: "6a521c61-55b5-4384-85c0-6534e63fb09e")
let boilerTargetUUID = CBUUID(string: "6a521c66-55b5-4384-85c0-6534e63fb09e")

var statusItemImage: NSImage?

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    
    var isConnected = false
    var boilerCurrent: Double = 0
    var boilerTarget: Double = 0
    var setPoint: Double = 0
    var waterStatus: String = "OK"

    var menu: NSMenu!
    var statusMenuItem: NSMenuItem!
    var currentTempMenuItem: NSMenuItem!
    var targetTempMenuItem: NSMenuItem!
    var basketTempMenuItem: NSMenuItem!
    var waterStatusMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let exePath = Bundle.main.executablePath ?? ""
        let exeDir = (exePath as NSString).deletingLastPathComponent
        let iconPath = (exeDir as NSString).appendingPathComponent("menubar/icon.png")
        
        if let image = NSImage(contentsOfFile: iconPath) {
            image.isTemplate = true
            statusItemImage = image
        }
        
        menu = NSMenu()
        
        statusMenuItem = NSMenuItem(title: "Status: Off", action: nil, keyEquivalent: "")
        menu.addItem(statusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        currentTempMenuItem = NSMenuItem(title: "Current: --", action: nil, keyEquivalent: "")
        menu.addItem(currentTempMenuItem)
        
        targetTempMenuItem = NSMenuItem(title: "Target: --", action: nil, keyEquivalent: "")
        menu.addItem(targetTempMenuItem)
        
        basketTempMenuItem = NSMenuItem(title: "Basket: --", action: nil, keyEquivalent: "")
        menu.addItem(basketTempMenuItem)
        
        waterStatusMenuItem = NSMenuItem(title: "Water: --", action: nil, keyEquivalent: "")
        menu.addItem(waterStatusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
        
        updateStatusBarItem()
        
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    func updateStatusBarItem() {
        guard let button = statusItem?.button else { return }
        
        if let image = statusItemImage {
            button.image = image
            button.imagePosition = .imageLeft
        }
        
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
        
        statusMenuItem.title = isConnected ? "Status: Connected" : "Status: Off"
        currentTempMenuItem.title = String(format: "Current: %.1f°C", boilerCurrent)
        targetTempMenuItem.title = String(format: "Target: %.1f°C", boilerTarget)
        let basketTemp = setPoint + 0.5 * (boilerCurrent - boilerTarget)
        basketTempMenuItem.title = String(format: "Basket: %.1f°C", basketTemp)
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
        updateStatusBarItem()
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
        default:
            break
        }
        
        updateStatusBarItem()
    }
}

app.run()