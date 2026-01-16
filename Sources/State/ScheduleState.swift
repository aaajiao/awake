import Foundation
import AppKit
import Observation

@Observable
final class ScheduleState {
    var sleepHour: Int = 23
    var sleepMinute: Int = 0
    var wakeEnabled: Bool = true
    var wakeHour: Int = 7
    var wakeMinute: Int = 0
    var days: RepeatDays = .everyDay
    var systemSchedule = SystemSchedule()

    var hasActiveSchedule: Bool { systemSchedule.hasSchedule }

    var sleepTimeDisplay: String { String(format: "%02d:%02d", sleepHour, sleepMinute) }
    var wakeTimeDisplay: String { String(format: "%02d:%02d", wakeHour, wakeMinute) }
    var sleepTimePmset: String { String(format: "%02d:%02d:00", sleepHour, sleepMinute) }
    var wakeTimePmset: String { String(format: "%02d:%02d:00", wakeHour, wakeMinute) }

    func menuBarIcon() -> NSImage {
        let name = hasActiveSchedule ? "sleep" : "awake"
        return ResourceLoader.loadIcon(name)
    }

    init() {
        load()
        syncWithSystem()
    }

    func syncWithSystem() {
        let output = PMSetService.readScheduleOutput()
        systemSchedule = SystemSchedule.parse(output)
    }

    func save() {
        UserDefaults.standard.set(sleepHour, forKey: StorageKey.sleepHour)
        UserDefaults.standard.set(sleepMinute, forKey: StorageKey.sleepMinute)
        UserDefaults.standard.set(wakeEnabled, forKey: StorageKey.wakeEnabled)
        UserDefaults.standard.set(wakeHour, forKey: StorageKey.wakeHour)
        UserDefaults.standard.set(wakeMinute, forKey: StorageKey.wakeMinute)
        UserDefaults.standard.set(days.rawValue, forKey: StorageKey.days)
    }

    func load() {
        if UserDefaults.standard.object(forKey: StorageKey.sleepHour) != nil {
            sleepHour = UserDefaults.standard.integer(forKey: StorageKey.sleepHour)
            sleepMinute = UserDefaults.standard.integer(forKey: StorageKey.sleepMinute)
            wakeEnabled = UserDefaults.standard.bool(forKey: StorageKey.wakeEnabled)
            wakeHour = UserDefaults.standard.integer(forKey: StorageKey.wakeHour)
            wakeMinute = UserDefaults.standard.integer(forKey: StorageKey.wakeMinute)
            if let daysStr = UserDefaults.standard.string(forKey: StorageKey.days),
               let d = RepeatDays(rawValue: daysStr) {
                days = d
            }
        }
    }
}
