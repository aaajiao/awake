import AppKit

class EventCoordinator {
    private var globalMonitor: Any?
    private var localMonitor: Any?

    var onOutsideClick: (() -> Void)?
    var onEscapeKey: (() -> Void)?

    func startMonitoring() {
        // Global monitor for clicks outside the app
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.onOutsideClick?()
        }

        // Local monitor for escape key
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == UIConstants.escapeKeyCode {
                self?.onEscapeKey?()
                return nil
            }
            return event
        }
    }

    func stopMonitoring() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    deinit {
        stopMonitoring()
    }
}
