import Foundation
import CoreBluetooth
import Combine

let serviceUUID = CBUUID(string: "6a521c59-55b5-4384-85c0-6534e63fb09e")
let setPointUUID = CBUUID(string: "6a521c60-55b5-4384-85c0-6534e63fb09e")
let boilerCurrentUUID = CBUUID(string: "6a521c61-55b5-4384-85c0-6534e63fb09e")
let boilerTargetUUID = CBUUID(string: "6a521c66-55b5-4384-85c0-6534e63fb09e")
let groupheadTempUUID = CBUUID(string: "6A521C62-55B5-4384-85C0-6534E63FB09E")

protocol BluetoothAdapter: AnyObject {
    var onValueRead: ((CharacteristicID, Data) -> Void)? { get set }
    var onConnect: (() -> Void)? { get set }
    var onDisconnect: (() -> Void)? { get set }
    func startScanning()
    func stopScanning()
}

enum CharacteristicID {
    case setPoint
    case boilerCurrent
    case boilerTarget
    case groupheadTemp
}

final class CoreBluetoothAdapter: NSObject, BluetoothAdapter {
    var onValueRead: ((CharacteristicID, Data) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: (() -> Void)?

    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?

    func startScanning() {
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func stopScanning() {
        centralManager?.stopScan()
    }

    private func scan() {
        centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension CoreBluetoothAdapter: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            scan()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if peripheral.name?.lowercased().starts(with: "argos") == true {
            central.stopScan()
            self.peripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async { [weak self] in
            self?.onConnect?()
        }
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.onDisconnect?()
        }
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension CoreBluetoothAdapter: CBPeripheralDelegate {
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

        let charID: CharacteristicID
        switch characteristic.uuid {
        case setPointUUID:
            charID = .setPoint
        case boilerCurrentUUID:
            charID = .boilerCurrent
        case boilerTargetUUID:
            charID = .boilerTarget
        case groupheadTempUUID:
            charID = .groupheadTemp
        default:
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.onValueRead?(charID, data)
        }
    }
}

final class MockBluetoothAdapter: BluetoothAdapter {
    var onValueRead: ((CharacteristicID, Data) -> Void)?
    var onConnect: (() -> Void)?
    var onDisconnect: (() -> Void)?

    func startScanning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            print("Mock: waiting for commands...")
            print("Mock commands: connect (c), disconnect (d), ready (r)")

            while let line = readLine()?.lowercased() {
                switch line {
                case "connect", "c":
                    self?.onConnect?()
                case "disconnect", "d":
                    self?.onDisconnect?()
                case "ready", "r":
                    let data = withUnsafeBytes(of: 91.0) { Data($0) }
                    self?.onValueRead?(.groupheadTemp, data)
                default:
                    print("Invalid command: \(line)")
                }
            }
        }
    }

    func stopScanning() {}
}

final class ArgosMachine: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var setPoint: Double = 0
    @Published var boilerCurrent: Double = 0
    @Published var boilerTarget: Double = 0
    @Published var groupheadTemp: Double = 0
    @Published var waterStatus: String = "OK"

    private let adapter: BluetoothAdapter

    init(adapter: BluetoothAdapter) {
        self.adapter = adapter
        self.adapter.onConnect = { [weak self] in
            self?.isConnected = true
            self?.boilerCurrent = 25.0
            self?.boilerTarget = 93.0
            self?.setPoint = 93.0
            self?.groupheadTemp = 25.0
        }
        self.adapter.onDisconnect = { [weak self] in
            self?.isConnected = false
            self?.boilerCurrent = 0
            self?.groupheadTemp = 0
        }
        self.adapter.onValueRead = { [weak self] charID, data in
            guard data.count >= 8 else { return }
            let value = data.withUnsafeBytes { $0.load(as: Double.self) }
            switch charID {
            case .setPoint:
                self?.setPoint = value
            case .boilerCurrent:
                self?.boilerCurrent = value
            case .boilerTarget:
                self?.boilerTarget = value
            case .groupheadTemp:
                self?.groupheadTemp = value
            }
        }
    }

    func initiate() {
        adapter.startScanning()
    }
}
