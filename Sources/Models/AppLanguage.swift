import Foundation

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
        if let raw = UserDefaults.standard.string(forKey: StorageKey.appLanguage),
           let lang = AppLanguage(rawValue: raw) {
            return lang
        }
        return .system
    }

    static func save(_ lang: AppLanguage) {
        UserDefaults.standard.set(lang.rawValue, forKey: StorageKey.appLanguage)
    }
}
