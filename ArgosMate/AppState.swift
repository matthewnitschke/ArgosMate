import Foundation
import Combine
import SwiftUI

enum TemperatureUnit: Int {
    case celsius = 0
    case fahrenheit = 1
}

class AppState: ObservableObject {
    @Published var notificationsDisabled = false
    @AppStorage("notifyWhenReady") var notifyWhenReady = true

    var temperatureUnit: TemperatureUnit {
        get {
            TemperatureUnit(rawValue: UserDefaults.standard.integer(forKey: "temperatureUnit")) ?? .celsius
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "temperatureUnit")
            objectWillChange.send()
        }
    }

    func convertTemperature(_ temp: Double) -> Double {
        if temperatureUnit == .fahrenheit {
            return (temp * 9/5) + 32
        }
        return temp
    }
}
