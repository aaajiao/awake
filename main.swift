import SwiftUI
import ServiceManagement
import Observation

// MARK: - Language
enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case chinese = "zh"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System / 系统"
        case .chinese: return "中文"
        case .english: return "English"
        }
    }

    static var saved: AppLanguage {
        if let raw = UserDefaults.standard.string(forKey: "appLanguage"),
           let lang = AppLanguage(rawValue: raw) {
            return lang
        }
        return .system
    }

    static func save(_ lang: AppLanguage) {
        UserDefaults.standard.set(lang.rawValue, forKey: "appLanguage")
        L10n.current = L10n.forLanguage(lang)
    }
}

// MARK: - Localization
struct L10n {
    static var current: L10n = forLanguage(AppLanguage.saved)

    let sleepTime: String
    let wakeTime: String
    let timedWake: String
    let wolNote: String
    let repeatLabel: String
    let enableSchedule: String
    let pauseSchedule: String
    let systemDetails: String
    let launchAtLogin: String
    let language: String
    let quit: String
    let stayAwake: String
    let sleepPrefix: String
    let wakePrefix: String
    let everyDay: String
    let weekdays: String
    let weekends: String
    let scheduleEnabled: String
    let schedulePaused: String
    let computerWillStayAwake: String
    let noSystemSchedule: String

    static func forLanguage(_ lang: AppLanguage) -> L10n {
        switch lang {
        case .chinese: return .chinese
        case .english: return .english
        case .system:
            let sysLang = Locale.preferredLanguages.first ?? "en"
            return sysLang.hasPrefix("zh") ? .chinese : .english
        }
    }

    static let chinese = L10n(
        sleepTime: "睡眠时间",
        wakeTime: "唤醒时间",
        timedWake: "定时唤醒",
        wolNote: "(使用 Wake on LAN 唤醒)",
        repeatLabel: "重复",
        enableSchedule: "启用调度",
        pauseSchedule: "暂停调度",
        systemDetails: "系统调度详情...",
        launchAtLogin: "开机自动启动",
        language: "语言",
        quit: "退出",
        stayAwake: "电脑保持唤醒",
        sleepPrefix: "睡眠",
        wakePrefix: "唤醒",
        everyDay: "每天",
        weekdays: "工作日",
        weekends: "周末",
        scheduleEnabled: "调度已启用",
        schedulePaused: "调度已暂停",
        computerWillStayAwake: "电脑将保持唤醒状态",
        noSystemSchedule: "当前无系统调度"
    )

    static let english = L10n(
        sleepTime: "Sleep Time",
        wakeTime: "Wake Time",
        timedWake: "Timed Wake",
        wolNote: "(Wake on LAN)",
        repeatLabel: "Repeat",
        enableSchedule: "Enable Schedule",
        pauseSchedule: "Pause Schedule",
        systemDetails: "System Schedule Details...",
        launchAtLogin: "Launch at Login",
        language: "Language",
        quit: "Quit",
        stayAwake: "Computer Stays Awake",
        sleepPrefix: "Sleep",
        wakePrefix: "Wake",
        everyDay: "Every Day",
        weekdays: "Weekdays",
        weekends: "Weekends",
        scheduleEnabled: "Schedule Enabled",
        schedulePaused: "Schedule Paused",
        computerWillStayAwake: "Computer will stay awake",
        noSystemSchedule: "No system schedule"
    )

    func daysDisplay(_ code: String) -> String {
        switch code {
        case "MTWRFSU": return everyDay
        case "MTWRF": return weekdays
        case "SU": return weekends
        default: return code
        }
    }
}

// MARK: - Models
enum RepeatDays: String, CaseIterable, Identifiable {
    case everyDay = "MTWRFSU"
    case weekdays = "MTWRF"
    case weekends = "SU"

    var id: String { rawValue }

    var displayName: String {
        L10n.current.daysDisplay(rawValue)
    }
}

struct SystemSchedule {
    var hasSchedule: Bool = false
    var sleepTime: String?
    var wakeTime: String?
    var days: String?

    static func parse(_ output: String) -> SystemSchedule {
        var state = SystemSchedule()

        guard output.contains("Repeating power events:") else {
            return state
        }

        let lines = output.components(separatedBy: "\n")
        var inRepeatingSection = false

        for line in lines {
            if line.contains("Repeating power events:") {
                inRepeatingSection = true
                continue
            }
            if line.contains("Scheduled power events:") {
                break
            }
            if inRepeatingSection && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                let trimmed = line.trimmingCharacters(in: .whitespaces)

                if trimmed.hasPrefix("sleep at") {
                    state.hasSchedule = true
                    if let timeRange = trimmed.range(of: #"\d{1,2}:\d{2}"#, options: .regularExpression) {
                        state.sleepTime = String(trimmed[timeRange])
                    }
                    state.days = extractDays(from: trimmed)
                }

                if trimmed.hasPrefix("wakepoweron at") || trimmed.hasPrefix("wakeorpoweron at") {
                    if let timeRange = trimmed.range(of: #"\d{1,2}:\d{2}"#, options: .regularExpression) {
                        state.wakeTime = String(trimmed[timeRange])
                    }
                }
            }
        }

        return state
    }

    private static func extractDays(from line: String) -> String {
        if line.contains("every day") { return "MTWRFSU" }
        if line.contains("weekdays only") { return "MTWRF" }
        if line.contains("weekends only") { return "SU" }
        if let match = line.range(of: #"[MTWRFSU]+"#, options: .regularExpression) {
            return String(line[match])
        }
        return "MTWRFSU"
    }
}

// MARK: - State
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

    var menuBarIcon: NSImage {
        let name = hasActiveSchedule ? "sleep" : "awake"
        let executablePath = Bundle.main.executablePath ?? ""
        let resourcesPath = (executablePath as NSString).deletingLastPathComponent + "/../Resources"
        let iconPath = "\(resourcesPath)/\(name).icns"

        if let icon = NSImage(contentsOfFile: iconPath) {
            icon.size = NSSize(width: 22, height: 22)
            icon.isTemplate = false
            return icon
        }
        return NSImage(systemSymbolName: hasActiveSchedule ? "moon.fill" : "moon", accessibilityDescription: nil) ?? NSImage()
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
        UserDefaults.standard.set(sleepHour, forKey: "sleepHour")
        UserDefaults.standard.set(sleepMinute, forKey: "sleepMinute")
        UserDefaults.standard.set(wakeEnabled, forKey: "wakeEnabled")
        UserDefaults.standard.set(wakeHour, forKey: "wakeHour")
        UserDefaults.standard.set(wakeMinute, forKey: "wakeMinute")
        UserDefaults.standard.set(days.rawValue, forKey: "days")
    }

    func load() {
        if UserDefaults.standard.object(forKey: "sleepHour") != nil {
            sleepHour = UserDefaults.standard.integer(forKey: "sleepHour")
            sleepMinute = UserDefaults.standard.integer(forKey: "sleepMinute")
            wakeEnabled = UserDefaults.standard.bool(forKey: "wakeEnabled")
            wakeHour = UserDefaults.standard.integer(forKey: "wakeHour")
            wakeMinute = UserDefaults.standard.integer(forKey: "wakeMinute")
            if let daysStr = UserDefaults.standard.string(forKey: "days"),
               let d = RepeatDays(rawValue: daysStr) {
                days = d
            }
        }
    }
}

// MARK: - Services
enum PMSetService {
    static func readScheduleOutput() -> String {
        shell("/usr/bin/pmset", ["-g", "sched"])
    }

    static func applySchedule(_ state: ScheduleState) {
        var cmd: String
        if state.wakeEnabled {
            cmd = "pmset repeat wakeorpoweron \(state.days.rawValue) \(state.wakeTimePmset) sleep \(state.days.rawValue) \(state.sleepTimePmset)"
        } else {
            cmd = "pmset repeat sleep \(state.days.rawValue) \(state.sleepTimePmset)"
        }
        runWithAdmin(cmd)
        state.save()
        state.syncWithSystem()
    }

    static func cancelSchedule(_ state: ScheduleState) {
        runWithAdmin("pmset repeat cancel")
        state.syncWithSystem()
    }

    private static func runWithAdmin(_ command: String) {
        let script = "do shell script \"\(command)\" with administrator privileges"
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
    }

    private static func shell(_ path: String, _ args: [String]) -> String {
        let task = Process()
        task.launchPath = path
        task.arguments = args
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        try? task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

enum LaunchService {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Launch at login error: \(error)")
        }
    }
}

// MARK: - Views
struct StatusHeaderView: View {
    let state: ScheduleState
    let l = L10n.current

    private var statusText: String {
        let sleepTime = state.systemSchedule.sleepTime ?? state.sleepTimeDisplay
        if let wakeTime = state.systemSchedule.wakeTime {
            return "\(l.sleepPrefix) \(sleepTime) → \(l.wakePrefix) \(wakeTime)"
        } else {
            return "\(l.sleepPrefix) \(sleepTime) (WOL)"
        }
    }

    var body: some View {
        if state.hasActiveSchedule {
            Text(statusText)
            Text(l.daysDisplay(state.systemSchedule.days ?? state.days.rawValue))
        } else {
            Text(l.stayAwake)
        }
    }
}

struct TimePickerMenu: View {
    @Binding var selectedHour: Int
    let onSelect: () -> Void

    var body: some View {
        ForEach(0..<24, id: \.self) { hour in
            Button(String(format: "%02d:00", hour)) {
                selectedHour = hour
                onSelect()
            }
        }
    }
}

struct MenuContent: View {
    @Bindable var state: ScheduleState
    @State private var launchAtLogin = LaunchService.isEnabled
    @State private var currentLanguage = AppLanguage.saved
    @State private var showingAlert = false
    @State private var alertMessage = ""
    let onLanguageChange: () -> Void

    var l: L10n { L10n.current }

    var body: some View {
        // Status Header
        StatusHeaderView(state: state)

        Divider()

        // Sleep Time
        Menu("\(l.sleepTime): \(state.sleepTimeDisplay)") {
            TimePickerMenu(selectedHour: $state.sleepHour) {
                state.save()
                if state.hasActiveSchedule {
                    PMSetService.applySchedule(state)
                }
            }
        }

        // Timed Wake Toggle
        Toggle(l.timedWake, isOn: $state.wakeEnabled)
            .onChange(of: state.wakeEnabled) { _, _ in
                state.save()
                if state.hasActiveSchedule {
                    PMSetService.applySchedule(state)
                }
            }

        // Wake Time (only if enabled)
        if state.wakeEnabled {
            Menu("\(l.wakeTime): \(state.wakeTimeDisplay)") {
                TimePickerMenu(selectedHour: $state.wakeHour) {
                    state.save()
                    if state.hasActiveSchedule {
                        PMSetService.applySchedule(state)
                    }
                }
            }
        } else {
            Text(l.wolNote)
        }

        // Repeat Days
        Menu("\(l.repeatLabel): \(state.days.displayName)") {
            ForEach(RepeatDays.allCases) { day in
                Button(day.displayName) {
                    state.days = day
                    state.save()
                    if state.hasActiveSchedule {
                        PMSetService.applySchedule(state)
                    }
                }
            }
        }

        Divider()

        // Main Action Button
        if state.hasActiveSchedule {
            Button("⏸ \(l.pauseSchedule)") {
                PMSetService.cancelSchedule(state)
            }
        } else {
            Button("▶ \(l.enableSchedule)") {
                PMSetService.applySchedule(state)
            }
        }

        Divider()

        // Launch at Login
        Toggle(l.launchAtLogin, isOn: $launchAtLogin)
            .onChange(of: launchAtLogin) { _, newValue in
                LaunchService.setEnabled(newValue)
            }

        // Language
        Menu("\(l.language): \(currentLanguage.displayName)") {
            ForEach(AppLanguage.allCases) { lang in
                Button(lang.displayName) {
                    currentLanguage = lang
                    AppLanguage.save(lang)
                    onLanguageChange()
                }
            }
        }

        // System Details
        Button(l.systemDetails) {
            let output = PMSetService.readScheduleOutput()
            alertMessage = output.isEmpty ? l.noSystemSchedule : output
            showAlert(title: l.systemDetails, message: alertMessage)
        }

        Divider()

        // Quit
        Button(l.quit) {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.runModal()
    }
}

// MARK: - App
@main
struct AwakeApp: App {
    @State private var state = ScheduleState()
    @State private var refreshID = UUID()

    var body: some Scene {
        MenuBarExtra {
            MenuContent(state: state) {
                refreshID = UUID()
            }
            .id(refreshID)
        } label: {
            Image(nsImage: state.menuBarIcon)
        }
        .menuBarExtraStyle(.menu)
    }
}
