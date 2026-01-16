import SwiftUI

struct ScheduleSection: View {
    @Bindable var state: ScheduleState
    let l: L10n
    let onScheduleChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Sleep Time Picker
            HStack {
                Text(l.sleepTime)
                Spacer()
                HourPicker(hour: $state.sleepHour)
                    .onChange(of: state.sleepHour) { _, _ in
                        onScheduleChange()
                    }
            }

            // Timed Wake Toggle
            Toggle(l.timedWake, isOn: $state.wakeEnabled)
                .onChange(of: state.wakeEnabled) { _, _ in
                    onScheduleChange()
                }

            // Wake Time (conditional)
            if state.wakeEnabled {
                HStack {
                    Text(l.wakeTime)
                    Spacer()
                    HourPicker(hour: $state.wakeHour)
                        .onChange(of: state.wakeHour) { _, _ in
                            onScheduleChange()
                        }
                }
            } else {
                Text(l.wolNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Repeat Days
            HStack {
                Text(l.repeatLabel)
                Spacer()
                Picker("", selection: $state.days) {
                    ForEach(RepeatDays.allCases) { day in
                        Text(day.displayName(l)).tag(day)
                    }
                }
                .labelsHidden()
                .frame(width: UIConstants.dayPickerWidth)
                .onChange(of: state.days) { _, _ in
                    onScheduleChange()
                }
            }
        }
    }
}
