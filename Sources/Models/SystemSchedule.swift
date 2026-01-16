import Foundation

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
