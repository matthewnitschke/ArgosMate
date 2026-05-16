import Foundation
import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gear") }
            IotSettingsView()
                .tabItem { Label("IoT", systemImage: "antenna.radiowaves.left.and.right") }
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

struct IotSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Section("URL") {
                TextField("", text: $appState.iotUrl)
                    .labelsHidden()
                    .lineLimit(1)
            }

            Section("Headers") {
                IotTextEditor(text: $appState.iotHeaders)
                    .frame(minHeight: 75)
            }

            Section("Body") {
                IotTextEditor(text: $appState.iotBody)
                    .frame(minHeight: 75)
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

                        Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)")
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


struct IotTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.smallSystemFontSize, weight: .regular)
        textView.textContainerInset = NSSize(width: 0, height: 4)
        textView.delegate = context.coordinator
        scrollView.borderType = .bezelBorder
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: IotTextEditor

        init(_ parent: IotTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
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
