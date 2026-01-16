import Foundation

// MARK: - Service Protocols for Testability

protocol PMSetServiceProtocol {
    func readScheduleOutput() -> String
    func applySchedule(_ state: ScheduleState)
    func cancelSchedule(_ state: ScheduleState)
}

protocol LaunchServiceProtocol {
    var isEnabled: Bool { get }
    func setEnabled(_ enabled: Bool)
}
