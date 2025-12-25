import Foundation
import UserNotifications

/// Service for managing local notifications
class NotificationService {
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Request notification permissions
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            print("NotificationService: Authorization \(granted ? "granted" : "denied")")
            return granted
        } catch {
            print("NotificationService: Authorization error: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Session Notifications
    
    /// Schedule a notification for when the session ends
    func scheduleSessionEndNotification(after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete! 🎉"
        content.body = "Great work! You've completed your focus session."
        content.sound = .default
        content.categoryIdentifier = "SESSION_COMPLETE"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "sessionEnd",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("NotificationService: Failed to schedule end notification: \(error)")
            } else {
                print("NotificationService: Scheduled session end notification in \(Int(seconds)) seconds")
            }
        }
    }
    
    /// Send immediate notification when session completes
    func sendSessionCompletedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete! 🎉"
        content.body = "Amazing! You stayed focused. Take a well-deserved break."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "sessionComplete-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil  // Deliver immediately
        )
        
        notificationCenter.add(request)
    }
    
    /// Schedule a reminder notification before session starts
    func scheduleSessionStartReminder(at date: Date, sessionName: String = "Focus Session") {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Starting Soon"
        content.body = "Your \(sessionName) is about to begin. Get ready to focus!"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date.addingTimeInterval(-300)  // 5 minutes before
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "sessionReminder",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    // MARK: - Blocked App Notifications
    
    /// Send notification when user attempts to open a blocked app
    func sendBlockedAppNotification(appName: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "Stay Focused! 🧘"
        
        if let appName = appName {
            content.body = "\(appName) is blocked during your focus session. You've got this!"
        } else {
            content.body = "This app is blocked during your focus session. Stay strong!"
        }
        
        content.sound = .default
        content.categoryIdentifier = "BLOCKED_APP"
        
        let request = UNNotificationRequest(
            identifier: "blockedApp-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request)
    }
    
    /// Send motivational message
    func sendMotivationalNotification() {
        let messages = [
            "You're doing great! Keep focusing. 💪",
            "Almost there! Stay with it. 🌟",
            "Focus is your superpower. 🦸",
            "Every minute of focus counts. ⏰",
            "You've got this! 🎯"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Focus Reminder"
        content.body = messages.randomElement() ?? messages[0]
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "motivational-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request)
    }
    
    // MARK: - Break Notifications
    
    /// Schedule break notifications
    func scheduleBreakNotification(after seconds: TimeInterval, breakDuration: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Break Time! ☕"
        content.body = "Take a \(breakDuration) minute break. Stretch, hydrate, rest your eyes."
        content.sound = .default
        content.categoryIdentifier = "BREAK_TIME"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "breakTime",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    /// Notify that break is over
    func sendBreakOverNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Break Over"
        content.body = "Time to get back to focusing! 🎯"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "breakOver-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request)
    }
    
    // MARK: - Utility Methods
    
    /// Cancel all pending notifications
    func cancelPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("NotificationService: Cancelled all pending notifications")
    }
    
    /// Cancel specific notification by identifier
    func cancelNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Get count of pending notifications
    func getPendingNotificationsCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }
}
