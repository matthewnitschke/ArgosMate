import Foundation
import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gear") }
            AboutSettingsView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
    }
}

struct GeneralSettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    @Environment(\.openURL) var openURL

    var body: some View {
        Form {
            Section {
                Picker("Measurement Unit", selection: $appState.temperatureUnit) {
                    Text("℉").tag(TemperatureUnit.fahrenheit)
                    Text("℃").tag(TemperatureUnit.celsius)
                }
                
                if appState.notificationsDisabled {
                    LabeledContent {
                        Button("System Settings") {
                            self.openURL(.notificationSettings)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Notifications are disabled")
                        }
                    }
                }
                Toggle(isOn: appState.$notifyWhenReady) {
                    Text("Notify when ready")
                        .opacity(appState.notificationsDisabled ? 0.5 : 1)
                }
                .disabled(appState.notificationsDisabled)

                VStack(alignment: .leading, spacing: 6) {
                    Toggle(isOn: appState.$disconnectWhenReady) {
                        Text("Disconnect when ready")
                    }
                    Text("The Argos machine supports only one Bluetooth connection at a time. Enabling this will disconnect ArgosMate when the machine is ready, allowing the Odyssey app to connect for brew charting.")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                
                LaunchAtLogin.Toggle()
                
                
            
            }
        }
        .formStyle(.grouped)
    }
}

struct AboutSettingsView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(nsImage: NSApp.applicationIconImage!)
                            .resizable()
                            .frame(width: 64, height: 64)

                        Text("ArgosMate")
                            .font(.title)

                        Text("Version 1.0")
                            .font(.footnote)
                        
                        
                        HStack(spacing: 1.5) {
                            Text("Made with").font(.footnote)
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.footnote)
                            Text("by").font(.footnote)
                            Link("Matthew Nitschke", destination: URL(string: "https://github.com/matthewnitschke")!).font(.footnote)
                        }
                    }
                    Spacer()
                }
            }
        }
        .formStyle(.grouped)
    }
}


extension URL {
    static let notificationSettings: URL = {
        let url = URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension")!
        
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return url
        }
        
        return url.appending(queryItems: [
            .init(name: "id", value: bundleId)
        ])
    }()
}
