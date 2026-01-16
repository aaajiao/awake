import Foundation
import Observation

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
