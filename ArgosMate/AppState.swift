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
    @AppStorage("iotMethod") var iotMethod = "POST"
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
        request.httpMethod = iotMethod

        if !iotHeaders.isEmpty, let data = iotHeaders.data(using: .utf8) {
            do {
                if let headers = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                    for (key, value) in headers {
                        request.setValue(value, forHTTPHeaderField: key)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Invalid IoT Headers JSON"
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                return
            }
        }

        if iotMethod != "GET" {
            request.httpBody = iotBody.data(using: .utf8)
        }

        let config = URLSessionConfiguration.ephemeral
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "IoT Request Failed"
                    alert.informativeText = error.localizedDescription
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode)
            {
                DispatchQueue.main.async {
                    var message = "HTTP \(httpResponse.statusCode)"
                    if let data = data, let body = String(data: data, encoding: .utf8), !body.isEmpty {
                        message += "\n\n\(body)"
                    }
                    let alert = NSAlert()
                    alert.messageText = "IoT Request Failed"
                    alert.informativeText = message
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }.resume()
    }
}
