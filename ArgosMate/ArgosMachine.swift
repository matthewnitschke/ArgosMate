import Foundation
import CoreBluetooth

enum FluidLevel: UInt32 {
    case ok = 0
    case needsWater = 1
}

let serviceUUID = CBUUID(string: "6a521c59-55b5-4384-85c0-6534e63fb09e")
let setPointUUID = CBUUID(string: "6a521c60-55b5-4384-85c0-6534e63fb09e")
let boilerCurrentUUID = CBUUID(string: "6a521c61-55b5-4384-85c0-6534e63fb09e")
let boilerTargetUUID = CBUUID(string: "6a521c66-55b5-4384-85c0-6534e63fb09e")
let groupheadTempUUID = CBUUID(string: "6A521C62-55B5-4384-85C0-6534E63FB09E")
let fluidLevelUUID = CBUUID(string: "6A521C63-55B5-4384-85C0-6534E63FB09E")

final class ArgosMachine: NSObject, ObservableObject {
    @Published var isConnected: Bool = false
    @Published var setPoint: Double = 0
    @Published var boilerCurrent: Double = 0
    @Published var boilerTarget: Double = 0
    @Published var groupheadTemp: Double = 0
    @Published var fluidLevel: FluidLevel = .ok

    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?

    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    private func scan() {
        centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension ArgosMachine: CBCentralManagerDelegate {
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
            self?.isConnected = true
        }
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.isConnected = false
            self?.boilerCurrent = 0
            self?.groupheadTemp = 0
            self?.fluidLevel = .ok
        }
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }

    func disconnect() {
        guard let peripheral = peripheral else { return }
        centralManager?.cancelPeripheralConnection(peripheral)
    }
}

extension ArgosMachine: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics([setPointUUID, boilerCurrentUUID, boilerTargetUUID, fluidLevelUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        guard data.count >= 8 || characteristic.uuid == fluidLevelUUID else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if characteristic.uuid == fluidLevelUUID {
                let rawValue = data.withUnsafeBytes { $0.load(as: UInt32.self) }
                self.fluidLevel = FluidLevel(rawValue: rawValue) ?? .ok
                return
            }

            let value = data.withUnsafeBytes { $0.load(as: Double.self) }
            switch characteristic.uuid {
            case setPointUUID:
                self.setPoint = value
            case boilerCurrentUUID:
                self.boilerCurrent = value
            case boilerTargetUUID:
                self.boilerTarget = value
            case groupheadTempUUID:
                self.groupheadTemp = value
            default:
                break
            }
        }
    }
}