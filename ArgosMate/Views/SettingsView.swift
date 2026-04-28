import Foundation
import SwiftUI

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
    @EnvironmentObject private var machine: ArgosMachine

    var body: some View {
        Form {
            Section {
                Toggle("Notify when ready", isOn: .constant(true))
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
