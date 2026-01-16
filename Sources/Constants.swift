import Foundation
import AppKit

// MARK: - UI Constants
enum UIConstants {
    static let escapeKeyCode: UInt16 = 53
    static let panelWidth: CGFloat = 280
    static let panelHeight: CGFloat = 400
    static let menuBarIconSize = NSSize(width: 22, height: 22)
    static let appIconSize: CGFloat = 32
    static let hourPickerWidth: CGFloat = 80
    static let dayPickerWidth: CGFloat = 100
    static let languagePickerWidth: CGFloat = 120
}

// MARK: - Storage Keys
enum StorageKey {
    static let appLanguage = "appLanguage"
    static let sleepHour = "sleepHour"
    static let sleepMinute = "sleepMinute"
    static let wakeEnabled = "wakeEnabled"
    static let wakeHour = "wakeHour"
    static let wakeMinute = "wakeMinute"
    static let days = "days"
}

// MARK: - Resource Loader
enum ResourceLoader {
    static func resourcePath(_ name: String, ext: String) -> String {
        let executablePath = Bundle.main.executablePath ?? ""
        let resourcesPath = (executablePath as NSString).deletingLastPathComponent + "/../Resources"
        return "\(resourcesPath)/\(name).\(ext)"
    }

    static func loadIcon(_ name: String, size: NSSize = UIConstants.menuBarIconSize) -> NSImage {
        let iconPath = resourcePath(name, ext: "icns")
        if let icon = NSImage(contentsOfFile: iconPath) {
            icon.size = size
            icon.isTemplate = false
            return icon
        }
        return NSImage(systemSymbolName: "moon", accessibilityDescription: nil) ?? NSImage()
    }

    static func loadAppIcon() -> NSImage? {
        let iconPath = resourcePath("AppIcon", ext: "icns")
        return NSImage(contentsOfFile: iconPath)
    }
}
