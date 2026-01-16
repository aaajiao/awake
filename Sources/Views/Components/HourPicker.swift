import SwiftUI

struct HourPicker: View {
    @Binding var hour: Int

    var body: some View {
        Picker("", selection: $hour) {
            ForEach(0..<24, id: \.self) { h in
                Text(String(format: "%02d:00", h)).tag(h)
            }
        }
        .labelsHidden()
        .frame(width: UIConstants.hourPickerWidth)
    }
}
