import Foundation

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
