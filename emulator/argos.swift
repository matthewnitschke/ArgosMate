import CoreBluetooth
import Foundation

class PeripheralManager: NSObject, CBPeripheralManagerDelegate {
    var manager: CBPeripheralManager!

    override init() {
        super.init()
        manager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            let serviceUUID = CBUUID(string: "1234")
            let advertisementData: [String: Any] = [
                CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
                CBAdvertisementDataLocalNameKey: "Mac_Emulator"
            ]
            manager.startAdvertising(advertisementData)
            print("Peripheral is advertising...")
        }
    }
}

let peripheral = PeripheralManager()
RunLoop.main.run()