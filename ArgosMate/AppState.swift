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
    @AppStorage("disconnectWhenReady") var disconnectWhenReady = false
    @AppStorage("iotUrl") var iotUrl = ""
    @AppStorage("iotHeaders") var iotHeaders = ""
    @AppStorage("iotBody") var iotBody = ""

    var temperatureUnit: TemperatureUnit {
        get {
            TemperatureUnit(rawValue: UserDefaults.standard.integer(forKey: "temperatureUnit")) ?? .celsius
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "temperatureUnit")
            objectWillChange.send()
        }
    }

    var hasIoTConfig: Bool {
        !iotUrl.isEmpty
    }

    func convertTemperature(_ temp: Double) -> Double {
        if temperatureUnit == .fahrenheit {
            return (temp * 9/5) + 32
        }
        return temp
    }

    func sendIoTRequest() {
        guard let url = URL(string: iotUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        if !iotHeaders.isEmpty, let data = iotHeaders.data(using: .utf8),
           let headers = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        request.httpBody = iotBody.data(using: .utf8)

        URLSession.shared.dataTask(with: request).resume()
    }
}
