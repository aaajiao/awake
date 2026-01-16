import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let windowManager = WindowManager()
    private let eventCoordinator = EventCoordinator()
    private let state = ScheduleState()
    private let localization = LocalizationState.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPanel()
        setupEventHandlers()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = state.menuBarIcon()
            button.action = #selector(togglePanel)
            button.target = self
        }
    }

    private func setupPanel() {
        windowManager.setupPanel(
            state: state,
            localization: localization,
            onIconUpdate: { [weak self] in
                self?.updateIcon()
            }
        )
    }

    private func setupEventHandlers() {
        eventCoordinator.onOutsideClick = { [weak self] in
            self?.windowManager.hidePanel()
        }
        eventCoordinator.onEscapeKey = { [weak self] in
            self?.windowManager.hidePanel()
        }
        eventCoordinator.startMonitoring()
    }

    private func updateIcon() {
        statusItem?.button?.image = state.menuBarIcon()
    }

    @objc private func togglePanel() {
        guard let button = statusItem?.button else { return }

        windowManager.togglePanel(
            button: button,
            state: state,
            localization: localization,
            onIconUpdate: { [weak self] in
                self?.updateIcon()
            }
        )

        // Update icon after toggle (in case state changed)
        updateIcon()
    }
}
