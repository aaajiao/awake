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
    }
}

// MARK: - Localization State (Observable for real-time updates)
@Observable
final class LocalizationState {
    static let shared = LocalizationState()

    var current: L10n
    var language: AppLanguage {
        didSet {
            AppLanguage.save(language)
            current = L10n.forLanguage(language)
        }
    }

    private init() {
        let lang = AppLanguage.saved
        self.language = lang
        self.current = L10n.forLanguage(lang)
    }
}

// MARK: - Localization
struct L10n {
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
        quit: "退出 Awake",
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
        quit: "Quit Awake",
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

    func displayName(_ l: L10n) -> String {
        l.daysDisplay(rawValue)
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

    func menuBarIcon() -> NSImage {
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

// MARK: - App Icon View
struct AppIconView: View {
    var body: some View {
        let executablePath = Bundle.main.executablePath ?? ""
        let resourcesPath = (executablePath as NSString).deletingLastPathComponent + "/../Resources"
        let iconPath = "\(resourcesPath)/AppIcon.icns"

        if let icon = NSImage(contentsOfFile: iconPath) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 32, height: 32)
        } else {
            Image(systemName: "moon.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundStyle(.blue)
        }
    }
}

// MARK: - Popover Content View
struct PopoverContentView: View {
    @Bindable var state: ScheduleState
    @Bindable var localization: LocalizationState
    @State private var launchAtLogin = LaunchService.isEnabled
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

            Divider()

            // Sleep Time Picker
            HStack {
                Text(l.sleepTime)
                Spacer()
                Picker("", selection: $state.sleepHour) {
                    ForEach(0..<24, id: \.self) { hour in
                        Text(String(format: "%02d:00", hour)).tag(hour)
                    }
                }
                .labelsHidden()
                .frame(width: 80)
                .onChange(of: state.sleepHour) { _, _ in
                    state.save()
                    if state.hasActiveSchedule {
                        PMSetService.applySchedule(state)
                        onIconUpdate()
                    }
                }
            }

            // Timed Wake Toggle
            Toggle(l.timedWake, isOn: $state.wakeEnabled)
                .onChange(of: state.wakeEnabled) { _, _ in
                    state.save()
                    if state.hasActiveSchedule {
                        PMSetService.applySchedule(state)
                        onIconUpdate()
                    }
                }

            // Wake Time (conditional)
            if state.wakeEnabled {
                HStack {
                    Text(l.wakeTime)
                    Spacer()
                    Picker("", selection: $state.wakeHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            Text(String(format: "%02d:00", hour)).tag(hour)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 80)
                    .onChange(of: state.wakeHour) { _, _ in
                        state.save()
                        if state.hasActiveSchedule {
                            PMSetService.applySchedule(state)
                            onIconUpdate()
                        }
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
                .frame(width: 100)
                .onChange(of: state.days) { _, _ in
                    state.save()
                    if state.hasActiveSchedule {
                        PMSetService.applySchedule(state)
                        onIconUpdate()
                    }
                }
            }

            Divider()

            // Main Action Button
            Button {
                if state.hasActiveSchedule {
                    PMSetService.cancelSchedule(state)
                } else {
                    PMSetService.applySchedule(state)
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

            Divider()

            // Settings Section
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
                .frame(width: 120)
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

            Divider()

            // Footer: Version + Quit
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
        .padding()
        .frame(width: 280)
        .fixedSize()
        .background(.regularMaterial)
    }
}

// MARK: - Panel Window (no arrow, flush with menu bar)
class PopoverPanel: NSPanel {
    override var canBecomeKey: Bool { true }

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isFloatingPanel = true
        level = .popUpMenu
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var panel: PopoverPanel?
    var state = ScheduleState()
    var localization = LocalizationState.shared
    var hostingController: NSHostingController<PopoverContentView>?
    var eventMonitor: Any?
    var localEventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPanel()
        setupEventMonitor()
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = state.menuBarIcon()
            button.action = #selector(togglePanel)
            button.target = self
        }
    }

    func setupPanel() {
        let contentView = PopoverContentView(
            state: state,
            localization: localization
        ) { [weak self] in
            self?.updateIcon()
        }

        hostingController = NSHostingController(rootView: contentView)

        // Create panel with initial size
        panel = PopoverPanel(contentRect: NSRect(x: 0, y: 0, width: 280, height: 400))
        panel?.contentViewController = hostingController
    }

    func setupEventMonitor() {
        // Global monitor for clicks outside the app
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.closePanel()
        }

        // Local monitor for escape key
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape key
                self?.closePanel()
                return nil
            }
            return event
        }
    }

    func updateIcon() {
        statusItem?.button?.image = state.menuBarIcon()
    }

    func closePanel() {
        panel?.orderOut(nil)
    }

    @objc func togglePanel() {
        guard let panel = panel, let button = statusItem?.button, let window = button.window else { return }

        if panel.isVisible {
            closePanel()
        } else {
            // Refresh state before showing
            state.syncWithSystem()
            updateIcon()

            // Update content view
            let contentView = PopoverContentView(
                state: state,
                localization: localization
            ) { [weak self] in
                self?.updateIcon()
            }
            hostingController?.rootView = contentView

            // Calculate position: flush below menu bar, centered on button
            let buttonRect = button.convert(button.bounds, to: nil)
            let screenRect = window.convertToScreen(buttonRect)

            // Get content size
            let contentSize = hostingController?.view.fittingSize ?? NSSize(width: 280, height: 400)

            // Position: top of panel at bottom of menu bar, centered on button
            let x = screenRect.midX - contentSize.width / 2
            let y = screenRect.minY - contentSize.height

            panel.setContentSize(contentSize)
            panel.setFrameOrigin(NSPoint(x: x, y: y))
            panel.makeKeyAndOrderFront(nil)
        }
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

// MARK: - App Entry Point
@main
struct AwakeApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}
