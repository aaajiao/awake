import SwiftUI
import AppKit

struct PopoverContentView: View {
    @Bindable var state: ScheduleState
    @Bindable var localization: LocalizationState
    let onIconUpdate: () -> Void

    var l: L10n { localization.current }

    private var statusText: String {
        let sleepTime = state.systemSchedule.sleepTime ?? state.sleepTimeDisplay
        if let wakeTime = state.systemSchedule.wakeTime {
            return "\(l.sleepPrefix) \(sleepTime) → \(l.wakePrefix) \(wakeTime)"
        } else {
            return "\(l.sleepPrefix) \(sleepTime) (WOL)"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // App Header with Icon
            headerSection

            Divider()

            // Schedule Settings
            ScheduleSection(
                state: state,
                l: l,
                onScheduleChange: handleScheduleChange
            )

            Divider()

            // Main Action Button
            actionButton

            Divider()

            // Settings Section
            SettingsSection(localization: localization, l: l)

            Divider()

            // Footer: Version + Quit
            footerSection
        }
        .padding()
        .frame(width: UIConstants.panelWidth)
        .fixedSize()
        .background(.regularMaterial)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(spacing: 10) {
            AppIconView()
            VStack(alignment: .leading, spacing: 2) {
                Text("Awake")
                    .font(.headline)
                if state.hasActiveSchedule {
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(l.stayAwake)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.bottom, 4)
    }

    private var actionButton: some View {
        Button {
            if state.hasActiveSchedule {
                PMSetService.cancelSchedule()
                state.syncWithSystem()
            } else {
                PMSetService.applySchedule(state)
                state.save()
                state.syncWithSystem()
            }
            onIconUpdate()
        } label: {
            HStack {
                Text(state.hasActiveSchedule ? "⏸ \(l.pauseSchedule)" : "▶ \(l.enableSchedule)")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(state.hasActiveSchedule ? .orange : .blue)
    }

    private var footerSection: some View {
        HStack {
            Text("Awake 0.4")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack(spacing: 4) {
                    Text(l.quit)
                    Text("⌘Q")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Actions

    private func handleScheduleChange() {
        state.save()
        if state.hasActiveSchedule {
            PMSetService.applySchedule(state)
            state.syncWithSystem()
            onIconUpdate()
        }
    }
}
