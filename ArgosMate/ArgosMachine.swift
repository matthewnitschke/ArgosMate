import Foundation
import CoreBluetooth
import Combine

let serviceUUID = CBUUID(string: "6a521c59-55b5-4384-85c0-6534e63fb09e")
let setPointUUID = CBUUID(string: "6a521c60-55b5-4384-85c0-6534e63fb09e")
let boilerCurrentUUID = CBUUID(string: "6a521c61-55b5-4384-85c0-6534e63fb09e")
let boilerTargetUUID = CBUUID(string: "6a521c66-55b5-4384-85c0-6534e63fb09e")
let groupheadTempUUID = CBUUID(string: "6A521C62-55B5-4384-85C0-6534E63FB09E")

final class ArgosMachine: NSObject, ObservableObject {
    @Published var isConnected: Bool = false
    @Published var setPoint: Double = 0
    @Published var boilerCurrent: Double = 0
    @Published var boilerTarget: Double = 0
    @Published var groupheadTemp: Double = 0
    @Published var waterStatus: String = "OK"

    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?

    override init() {
        super.init()
    }

    func initiate() {
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
        }
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension ArgosMachine: CBPeripheralDelegate {
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
        let value = data.withUnsafeBytes { $0.load(as: Double.self) }

        DispatchQueue.main.async { [weak self] in
            switch characteristic.uuid {
            case setPointUUID:
                self?.setPoint = value
            case boilerCurrentUUID:
                self?.boilerCurrent = value
            case boilerTargetUUID:
                self?.boilerTarget = value
            case groupheadTempUUID:
                self?.groupheadTemp = value
            default:
                break
            }
        }
    }
}
