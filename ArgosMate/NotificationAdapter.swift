import Foundation
import UserNotifications
import Combine

final class NotificationAdapter: ObservableObject {
    @Published var isReady: Bool = false

    private let machine: ArgosMachine
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    private var hasNotifiedReady = false
    private let temperatureThreshold: Double = 1.0

    init(machine: ArgosMachine, appState: AppState) {
        self.machine = machine
        self.appState = appState
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        setupBindings()
    }

    private func setupBindings() {
        Publishers.CombineLatest(machine.$boilerCurrent, machine.$boilerTarget)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] current, target in
                self?.checkReady(current: current, target: target)
            }
            .store(in: &cancellables)
    }

    private func checkReady(current: Double, target: Double) {
        let ready = target > 0 && abs(current - target) <= temperatureThreshold
        if ready && !isReady && !hasNotifiedReady {
            sendNotification(target: target)
            hasNotifiedReady = true
        } else if !ready {
            hasNotifiedReady = false
        }
        isReady = ready
    }

    private func sendNotification(target: Double) {
        if !appState.notifyWhenReady {
            return
        }
        
        let convertedTemp = appState.convertTemperature(target)
        let unitSymbol = appState.temperatureUnit == .celsius ? "°C" : "°F"
        let content = UNMutableNotificationContent()
        content.title = "Argos Ready"
        content.body = String(format: "Machine reached %.1f\(unitSymbol)", convertedTemp)
        content.sound = .default
        content.userInfo = ["icon": "AppIcon"]
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
