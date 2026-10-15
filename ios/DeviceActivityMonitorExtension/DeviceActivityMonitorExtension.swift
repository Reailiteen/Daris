import DeviceActivity
import ManagedSettings
import FamilyControls
import UserNotifications

/// DeviceActivity Monitor Extension for handling schedule events
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    /// The managed settings store for applying restrictions
    private let store = ManagedSettingsStore()
    
    /// App group identifier for shared data
    private let appGroupIdentifier = "group.com.focusflow.shared"
    
    // MARK: - DeviceActivityMonitor Overrides
    
    /// Called when a monitored activity interval starts
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        print("DeviceActivityMonitor: Interval started for \(activity.rawValue)")

        if activity.rawValue == "screenTimeUsage" {
            // Screen time credit — do NOT apply shields.
            // Apps were already unblocked by the main app. We just track usage via events.
            return
        }

        // Focus session — apply shields
        emergencyUnblockIfNeeded()
        if let selection = loadSelection() {
            applyShields(for: selection)
        }
        emergencyUnblockIfNeeded()
        sendNotification(title: "Focus Session Started", body: "Stay focused! Distracting apps are now blocked.")
    }
    
    /// Called when a monitored activity interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        print("DeviceActivityMonitor: Interval ended for \(activity.rawValue)")

        if activity.rawValue == "screenTimeUsage" {
            // Screen time credit exhausted — re-block apps
            if let selection = loadSelection() {
                applyShields(for: selection)
            }
            if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                sharedDefaults.set(false, forKey: "screenTimeSessionActive")
                sharedDefaults.set(0, forKey: "screenTimeBalanceMinutes")
            }
            sendNotification(
                title: "Screen Time Used Up",
                body: "Your earned screen time has ended. Study more to earn more!"
            )
            return
        }

        // Focus session ended — keep shields in place (apps stay blocked by default).
        // User needs screen time credit to unblock.
        sendNotification(title: "Focus Session Complete! 🎉", body: "Great job! Your focus session has ended.")
        markSessionComplete()
    }

    /// Called when a usage threshold is reached.
    /// For screen time sessions, each "st_min_N" event = N minutes of actual blocked-app usage.
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        print("DeviceActivityMonitor: Event threshold reached - \(event.rawValue)")

        guard activity.rawValue == "screenTimeUsage",
              event.rawValue.hasPrefix("st_min_"),
              let minuteUsed = Int(event.rawValue.dropFirst("st_min_".count)) else { return }

        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else { return }

        let balance = sharedDefaults.integer(forKey: "screenTimeBalanceMinutes")
        sharedDefaults.set(minuteUsed, forKey: "screenTimeMinutesUsed")

        print("DeviceActivityMonitor: Screen time used \(minuteUsed)/\(balance) min")

        if minuteUsed >= balance {
            // Balance exhausted — re-block and shut down
            if let selection = loadSelection() {
                applyShields(for: selection)
            }
            sharedDefaults.set(false, forKey: "screenTimeSessionActive")
            sendNotification(
                title: "Screen Time Used Up",
                body: "Your earned screen time has ended. Study more to earn more!"
            )
        } else if balance - minuteUsed == 5 {
            sendNotification(
                title: "Screen Time Ending Soon ⏰",
                body: "You have 5 minutes of screen time left."
            )
        }
    }

    /// Called when there's a warning before interval starts
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        print("DeviceActivityMonitor: Interval will start warning for \(activity.rawValue)")
    }

    /// Called as warning before interval ends
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        print("DeviceActivityMonitor: Interval will end warning for \(activity.rawValue)")

        if activity.rawValue == "screenTimeUsage" {
            sendNotification(
                title: "Screen Time Ending Soon ⏰",
                body: "You have ~5 minutes of screen time credit left."
            )
            return
        }

        sendNotification(title: "Session Ending Soon", body: "Your focus session will end in a few minutes.")
    }
    
    // MARK: - Helper Methods
    
    /// Load the saved FamilyActivitySelection from App Group
    private func loadSelection() -> FamilyActivitySelection? {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier),
              let data = sharedDefaults.data(forKey: "selectedFamilyActivity") else {
            print("DeviceActivityMonitor: No selection found")
            return nil
        }
        
        do {
            let decoder = PropertyListDecoder()
            return try decoder.decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("DeviceActivityMonitor: Failed to decode selection - \(error)")
            return nil
        }
    }
    
    /// Apply shields to the selected apps and categories
    /// CRITICAL: Includes safeguard to prevent FocusFlow from being blocked
    private func applyShields(for selection: FamilyActivitySelection) {
        // CRITICAL: Check emergency flag BEFORE applying shields
        // If flag is set, don't apply shields at all - this prevents FocusFlow from being blocked
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            let emergencyUnblock = sharedDefaults.bool(forKey: "emergencyUnblockFocusFlow")
            if emergencyUnblock {
                print("DeviceActivityMonitor: 🚨 EMERGENCY FLAG DETECTED - Skipping shield application to prevent FocusFlow lock!")
                sharedDefaults.set(false, forKey: "emergencyUnblockFocusFlow")
                return
            }
        }
        
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        
        // Save blocking state
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.set(true, forKey: "isBlockingActive")
        }
        
        print("DeviceActivityMonitor: Applied shields to \(selection.applicationTokens.count) apps")
        
        // CRITICAL SAFETY: Immediately check and unblock if FocusFlow might be blocked
        // Check immediately (no delay) to prevent FocusFlow from being locked
        emergencyUnblockIfNeeded()
        
        // Also check after a short delay as backup
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.emergencyUnblockIfNeeded()
        }
    }
    
    /// Emergency unblock mechanism - ensures FocusFlow is never permanently locked
    /// This runs immediately whenever shields are applied or intervals start
    private func emergencyUnblockIfNeeded() {
        // Check if blocking is currently active
        let isBlocking = store.shield.applications != nil || 
                        store.shield.applicationCategories != nil || 
                        store.shield.webDomains != nil
        
        if isBlocking {
            // ALWAYS check for emergency unblock flag - this is set by BlockingEngine
            // when blocking starts, as a safeguard
            if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                let emergencyUnblock = sharedDefaults.bool(forKey: "emergencyUnblockFocusFlow")
                
                if emergencyUnblock {
                    print("DeviceActivityMonitor: 🚨🚨🚨 EMERGENCY UNBLOCK TRIGGERED 🚨🚨🚨")
                    print("DeviceActivityMonitor: FocusFlow may be blocked. Unblocking ALL apps immediately to prevent permanent lock!")
                    removeAllShields()
                    sharedDefaults.set(false, forKey: "emergencyUnblockFocusFlow")
                    
                    // Send notification that unblock happened
                    sendNotification(
                        title: "Safety Unblock Activated",
                        body: "FocusFlow was unblocked to prevent self-lock. Please restart your focus session."
                    )
                    return
                }
            }
            
            // NOTE: 30-minute auto-unblock removed — persistent blocking is intentional.
            // The emergency flag mechanism above is sufficient for self-lock protection.
        }
    }
    
    /// Remove all shields
    private func removeAllShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        // Clear blocking state
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.set(false, forKey: "isBlockingActive")
        }
        
        print("DeviceActivityMonitor: Removed all shields")
    }
    
    /// Mark the current session as complete
    private func markSessionComplete() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else { return }
        
        sharedDefaults.set(true, forKey: "sessionCompletedSuccessfully")
        sharedDefaults.removeObject(forKey: "currentSession")
    }
    
    /// Send a local notification
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("DeviceActivityMonitor: Failed to send notification - \(error)")
            }
        }
    }
}

