import AppKit
import SwiftUI

class WindowManager {
    private var panel: PopoverPanel?
    private var hostingController: NSHostingController<PopoverContentView>?

    /// Gap between menu bar and panel (matches macOS system style)
    private let menuBarGap: CGFloat = 10

    var isVisible: Bool {
        panel?.isVisible ?? false
    }

    func setupPanel(state: ScheduleState, localization: LocalizationState, onIconUpdate: @escaping () -> Void) {
        let contentView = PopoverContentView(
            state: state,
            localization: localization,
            onIconUpdate: onIconUpdate
        )

        hostingController = NSHostingController(rootView: contentView)

        panel = PopoverPanel(contentRect: NSRect(
            x: 0,
            y: 0,
            width: UIConstants.panelWidth,
            height: UIConstants.panelHeight
        ))
        panel?.contentViewController = hostingController
    }

    func showPanel(below button: NSStatusBarButton, state: ScheduleState, localization: LocalizationState, onIconUpdate: @escaping () -> Void) {
        guard let panel = panel, let window = button.window else { return }

        // Refresh state before showing
        state.syncWithSystem()

        // Update content view
        let contentView = PopoverContentView(
            state: state,
            localization: localization,
            onIconUpdate: onIconUpdate
        )
        hostingController?.rootView = contentView

        // Calculate position: below menu bar with gap, centered on button
        let buttonRect = button.convert(button.bounds, to: nil)
        let screenRect = window.convertToScreen(buttonRect)

        // Get content size
        let contentSize = hostingController?.view.fittingSize ?? NSSize(
            width: UIConstants.panelWidth,
            height: UIConstants.panelHeight
        )

        // Position: top of panel below menu bar with gap, centered on button
        let x = screenRect.midX - contentSize.width / 2
        let y = screenRect.minY - contentSize.height - menuBarGap

        panel.setContentSize(contentSize)
        panel.setFrameOrigin(NSPoint(x: x, y: y))
        panel.makeKeyAndOrderFront(nil)
    }

    func hidePanel() {
        panel?.orderOut(nil)
    }

    func togglePanel(button: NSStatusBarButton, state: ScheduleState, localization: LocalizationState, onIconUpdate: @escaping () -> Void) {
        if isVisible {
            hidePanel()
        } else {
            showPanel(below: button, state: state, localization: localization, onIconUpdate: onIconUpdate)
        }
    }
}
