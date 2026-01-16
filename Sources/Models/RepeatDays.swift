import Foundation

enum RepeatDays: String, CaseIterable, Identifiable {
    case everyDay = "MTWRFSU"
    case weekdays = "MTWRF"
    case weekends = "SU"

    var id: String { rawValue }

    func displayName(_ l: L10n) -> String {
        l.daysDisplay(rawValue)
    }
}
