import Foundation
import DeviceActivity
import FamilyControls

/// Service for managing device activity schedules
class ScheduleManager {
    static let shared = ScheduleManager()
    
    /// The device activity center for managing schedules
    private let center = DeviceActivityCenter()
    
    /// Activity name for focus sessions
    private let focusSessionActivity = DeviceActivityName("focusSession")
    
    /// App group identifier for sharing state with extensions
    private let appGroupIdentifier = "group.com.focusflow.shared"
    
    private init() {}
    
    // MARK: - Schedule Management
    
    /// Schedule a focus session
    /// - Parameters:
    ///   - duration: The duration of the focus session in seconds
    ///   - selection: The apps/categories to monitor
    func scheduleSession(duration: TimeInterval, selection: FamilyActivitySelection) {
        let now = Date()
        let endTime = now.addingTimeInterval(duration)
        
        // Convert to DateComponents
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endTime)
        
        // Create the schedule
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false,
            warningTime: nil
        )
        
        // Save schedule info for the monitor extension
        saveScheduleInfo(startTime: now, endTime: endTime, selection: selection)
        
        do {
            // Start monitoring with the schedule
            try center.startMonitoring(
                focusSessionActivity,
                during: schedule
            )
            print("ScheduleManager: Started monitoring until \(endTime)")
        } catch {
            print("ScheduleManager: Failed to start monitoring: \(error)")
        }
    }
    
    /// Schedule a session with specific start and end times
    /// - Parameters:
    ///   - startTime: When the session should start
    ///   - endTime: When the session should end
    ///   - selection: The apps/categories to monitor
    func scheduleSession(startTime: Date, endTime: Date, selection: FamilyActivitySelection) {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endTime)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false,
            warningTime: nil
        )
        
        saveScheduleInfo(startTime: startTime, endTime: endTime, selection: selection)
        
        do {
            try center.startMonitoring(focusSessionActivity, during: schedule)
            print("ScheduleManager: Scheduled session from \(startTime) to \(endTime)")
        } catch {
            print("ScheduleManager: Failed to schedule session: \(error)")
        }
    }
    
    /// Cancel all active schedules
    func cancelAllSchedules() {
        center.stopMonitoring([focusSessionActivity])
        clearScheduleInfo()
        print("ScheduleManager: Cancelled all schedules")
    }
    
    /// Get all active schedule names
    var activeSchedules: [DeviceActivityName] {
        return center.activities.map { $0 }
    }
    
    /// Check if there's an active schedule
    var hasActiveSchedule: Bool {
        return !center.activities.isEmpty
    }
    
    // MARK: - Schedule Info Persistence
    
    /// Save schedule information for extension access
    private func saveScheduleInfo(startTime: Date, endTime: Date, selection: FamilyActivitySelection) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else { return }
        
        sharedDefaults.set(startTime, forKey: "scheduleStartTime")
        sharedDefaults.set(endTime, forKey: "scheduleEndTime")
        
        // Save selection for the extension to use
        do {
            let encoder = PropertyListEncoder()
            let selectionData = try encoder.encode(selection)
            sharedDefaults.set(selectionData, forKey: "scheduledSelection")
        } catch {
            print("ScheduleManager: Failed to save selection: \(error)")
        }
    }
    
    /// Clear schedule information
    private func clearScheduleInfo() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else { return }
        
        sharedDefaults.removeObject(forKey: "scheduleStartTime")
        sharedDefaults.removeObject(forKey: "scheduleEndTime")
        sharedDefaults.removeObject(forKey: "scheduledSelection")
    }
    
    /// Load schedule information (for extensions)
    static func loadScheduleInfo() -> (startTime: Date?, endTime: Date?, selection: FamilyActivitySelection?) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.focusflow.shared") else {
            return (nil, nil, nil)
        }
        
        let startTime = sharedDefaults.object(forKey: "scheduleStartTime") as? Date
        let endTime = sharedDefaults.object(forKey: "scheduleEndTime") as? Date
        
        var selection: FamilyActivitySelection? = nil
        if let selectionData = sharedDefaults.data(forKey: "scheduledSelection") {
            do {
                let decoder = PropertyListDecoder()
                selection = try decoder.decode(FamilyActivitySelection.self, from: selectionData)
            } catch {
                print("ScheduleManager: Failed to load selection: \(error)")
            }
        }
        
        return (startTime, endTime, selection)
    }
}

// MARK: - Recurring Schedules
extension ScheduleManager {
    /// Schedule a daily focus session
    /// - Parameters:
    ///   - startHour: Hour to start (0-23)
    ///   - startMinute: Minute to start (0-59)
    ///   - durationMinutes: Duration in minutes
    func scheduleDailySession(startHour: Int, startMinute: Int, durationMinutes: Int) {
        let endMinute = (startMinute + durationMinutes) % 60
        let endHour = (startHour + (startMinute + durationMinutes) / 60) % 24
        
        let startComponents = DateComponents(hour: startHour, minute: startMinute)
        let endComponents = DateComponents(hour: endHour, minute: endMinute)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: true,  // Repeat daily
            warningTime: DateComponents(minute: 5)  // Warn 5 minutes before
        )
        
        do {
            let dailyActivity = DeviceActivityName("dailyFocusSession")
            try center.startMonitoring(dailyActivity, during: schedule)
            print("ScheduleManager: Scheduled daily session at \(startHour):\(startMinute)")
        } catch {
            print("ScheduleManager: Failed to schedule daily session: \(error)")
        }
    }
}
