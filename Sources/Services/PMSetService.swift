import Foundation
import AppKit

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
    }

    static func cancelSchedule() {
        runWithAdmin("pmset repeat cancel")
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
