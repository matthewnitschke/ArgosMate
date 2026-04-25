import Foundation
import CoreBluetooth

let serviceUUID = CBUUID(string: "6a521c59-55b5-4384-85c0-6534e63fb09e")
let setPointUUID = CBUUID(string: "6a521c60-55b5-4384-85c0-6534e63fb09e")
let boilerCurrentUUID = CBUUID(string: "6a521c61-55b5-4384-85c0-6534e63fb09e")
let boilerTargetUUID = CBUUID(string: "6a521c66-55b5-4384-85c0-6534e63fb09e")
let groupheadTempUUID = CBUUID(string: "6A521C62-55B5-4384-85C0-6534E63FB09E")

class ArgosMachine: NSObject {
    var onUpdate: ((ArgosMachine) -> Void)?

    var isConnected: Bool = false
    var setPoint: Double = 0
    var boilerCurrent: Double = 0
    var boilerTarget: Double = 0
    var groupheadTemp: Double = 0
    var waterStatus: String = "OK"

    func initiate() {}
}

class PhysicalArgos: ArgosMachine, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!

    override func initiate() {
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func startScan() {
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension PhysicalArgos {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name?.lowercased().starts(with: "argos") == true {
            central.stopScan()
            self.peripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        onUpdate?(self)
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        onUpdate?(self)
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension PhysicalArgos {
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
        case groupheadTempUUID:
            groupheadTemp = temperature
        default:
            return
        }

        onUpdate?(self)
    }
}

class MockArgos: ArgosMachine {

    override func initiate() {
        startCommandLoop()
    }

    private func startCommandLoop() {
        print("Mock commands: connect (c), disconnect (d), ready (r)")

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            while let line = readLine()?.lowercased() {
                switch line {
                case "connect", "c":
                    self?.connect()
                case "disconnect", "d":
                    self?.disconnect()
                case "ready", "r":
                    self?.ready()
                default:
                    print("Invalid command: \(line)")
                }
                self?.printState()
            }
        }
    }

    func connect() {
        isConnected = true
        boilerCurrent = 25.0
        boilerTarget = 93.0
        setPoint = 93.0
        groupheadTemp = 25.0
        onUpdate?(self)
    }

    func disconnect() {
        isConnected = false
        boilerCurrent = 0
        groupheadTemp = 0
        onUpdate?(self)
    }

    func ready() {
        boilerCurrent = boilerTarget
        groupheadTemp = boilerTarget - 2.0
        onUpdate?(self)
    }


    func printState() {
        print("""
            --- Machine State ---
            isConnected: \(isConnected)
            setPoint: \(setPoint)
            boilerCurrent: \(boilerCurrent)
            boilerTarget: \(boilerTarget)
            groupheadTemp: \(groupheadTemp)
            ---------------------
            """)
    }
}