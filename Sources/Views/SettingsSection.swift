import SwiftUI
import AppKit

struct SettingsSection: View {
    @Bindable var localization: LocalizationState
    @State private var launchAtLogin = LaunchService.isEnabled
    let l: L10n

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(l.launchAtLogin, isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    LaunchService.setEnabled(newValue)
                }

            HStack {
                Text(l.language)
                Spacer()
                Picker("", selection: $localization.language) {
                    ForEach(AppLanguage.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                }
                .labelsHidden()
                .frame(width: UIConstants.languagePickerWidth)
            }

            Button(l.systemDetails) {
                let output = PMSetService.readScheduleOutput()
                let message = output.isEmpty ? l.noSystemSchedule : output
                let alert = NSAlert()
                alert.messageText = l.systemDetails
                alert.informativeText = message
                alert.runModal()
            }
            .buttonStyle(.link)
        }
    }
}
