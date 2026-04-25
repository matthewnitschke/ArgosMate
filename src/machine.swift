import Foundation
import CoreBluetooth

let serviceUUID = CBUUID(string: "6a521c59-55b5-4384-85c0-6534e63fb09e")
let setPointUUID = CBUUID(string: "6a521c60-55b5-4384-85c0-6534e63fb09e")
let boilerCurrentUUID = CBUUID(string: "6a521c61-55b5-4384-85c0-6534e63fb09e")
let boilerTargetUUID = CBUUID(string: "6a521c66-55b5-4384-85c0-6534e63fb09e")
let ghTempUUID = CBUUID(string: "6A521C62-55B5-4384-85C0-6534E63FB09E")

protocol ArgosMachineDelegate: AnyObject {
    func argosMachineDidConnect(_ machine: ArgosMachine)
    func argosMachineDidDisconnect(_ machine: ArgosMachine)
    func argosMachine(_ machine: ArgosMachine, didUpdateSetPoint setPoint: Double)
    func argosMachine(_ machine: ArgosMachine, didUpdateBoilerCurrent current: Double)
    func argosMachine(_ machine: ArgosMachine, didUpdateBoilerTarget target: Double)
    func argosMachine(_ machine: ArgosMachine, didUpdateGroupheadTemp temp: Double)
    func argosMachine(_ machine: ArgosMachine, didUpdateWaterStatus status: String)
}

class ArgosMachine: NSObject {
    weak var delegate: ArgosMachineDelegate?

    var isConnected: Bool = false
    var setPoint: Double = 0
    var boilerCurrent: Double = 0
    var boilerTarget: Double = 0
    var groupheadTemp: Double = 0
    var waterStatus: String = "OK"

    func initiate() {}
}

class RealArgosMachine: ArgosMachine, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!

    override func initiate() {
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func startScan() {
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension RealArgosMachine {
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
        delegate?.argosMachineDidConnect(self)
        peripheral.discoverServices([serviceUUID])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        delegate?.argosMachineDidDisconnect(self)
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
}

extension RealArgosMachine {
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
            delegate?.argosMachine(self, didUpdateSetPoint: temperature)
        case boilerCurrentUUID:
            boilerCurrent = temperature
            delegate?.argosMachine(self, didUpdateBoilerCurrent: temperature)
        case boilerTargetUUID:
            boilerTarget = temperature
            delegate?.argosMachine(self, didUpdateBoilerTarget: temperature)
        case ghTempUUID:
            groupheadTemp = temperature
            delegate?.argosMachine(self, didUpdateGroupheadTemp: temperature)
        default:
            break
        }
    }
}

class MockArgosMachine: ArgosMachine {
    private var heatingTimer: Timer?
    private var updateTimer: Timer?

    override func initiate() {
        isConnected = true
        delegate?.argosMachineDidConnect(self)

        boilerCurrent = 25.0
        boilerTarget = 93.0
        setPoint = 93.0
        groupheadTemp = 25.0

        delegate?.argosMachine(self, didUpdateSetPoint: setPoint)
        delegate?.argosMachine(self, didUpdateBoilerCurrent: boilerCurrent)
        delegate?.argosMachine(self, didUpdateBoilerTarget: boilerTarget)
        delegate?.argosMachine(self, didUpdateGroupheadTemp: groupheadTemp)
        delegate?.argosMachine(self, didUpdateWaterStatus: waterStatus)

        startHeatingSimulation()
    }

    private func startHeatingSimulation() {
        let startTemp = 25.0
        let targetTemp = 93.0
        let duration: TimeInterval = 4.0
        let steps = 40
        let stepDuration = duration / Double(steps)
        let tempIncrement = (targetTemp - startTemp) / Double(steps)

        var currentStep = 0

        updateTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            currentStep += 1
            if currentStep >= steps {
                timer.invalidate()
                self.boilerCurrent = targetTemp
                self.groupheadTemp = targetTemp - 2.0
                self.delegate?.argosMachine(self, didUpdateBoilerCurrent: targetTemp)
                self.delegate?.argosMachine(self, didUpdateGroupheadTemp: targetTemp - 2.0)
            } else {
                self.boilerCurrent += tempIncrement
                self.groupheadTemp += tempIncrement
                self.delegate?.argosMachine(self, didUpdateBoilerCurrent: self.boilerCurrent)
                self.delegate?.argosMachine(self, didUpdateGroupheadTemp: self.groupheadTemp)
            }
        }
    }
}