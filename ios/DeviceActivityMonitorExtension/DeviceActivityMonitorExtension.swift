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
        
        // CRITICAL: Check for emergency unblock BEFORE applying shields
        // This ensures FocusFlow is never blocked
        emergencyUnblockIfNeeded()
        
        // Load the saved selection and apply shields
        if let selection = loadSelection() {
            applyShields(for: selection)
        }
        
        // Check again after applying shields
        emergencyUnblockIfNeeded()
        
        // Send notification
        sendNotification(title: "Focus Session Started", body: "Stay focused! Distracting apps are now blocked.")
    }
    
    /// Called when a monitored activity interval ends
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        print("DeviceActivityMonitor: Interval ended for \(activity.rawValue)")
        
        // Remove all shields
        removeAllShields()
        
        // Send completion notification
        sendNotification(title: "Focus Session Complete! 🎉", body: "Great job! Your focus session has ended.")
        
        // Update session state
        markSessionComplete()
    }
    
    /// Called when a usage threshold is reached
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        print("DeviceActivityMonitor: Event threshold reached - \(event.rawValue)")
        
        // Could be used for break reminders or warnings
    }
    
    /// Called when there's a warning before interval ends
    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        print("DeviceActivityMonitor: Interval will start warning for \(activity.rawValue)")
    }
    
    /// Called as warning before interval ends
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        print("DeviceActivityMonitor: Interval will end warning for \(activity.rawValue)")
        
        // Send warning notification
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
            
            // Additional safeguard: If blocking has been active for more than 30 minutes,
            // automatically unblock as a safety measure (prevents permanent lock)
            if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                if let lastBlockTime = sharedDefaults.object(forKey: "lastBlockTime") as? Date {
                    let timeSinceBlock = Date().timeIntervalSince(lastBlockTime)
                    // If blocked for more than 30 minutes, unblock as safety measure
                    if timeSinceBlock > 1800 { // 30 minutes
                        print("DeviceActivityMonitor: ⚠️ SAFETY TIMEOUT - Blocking active for >30min. Auto-unblocking.")
                        removeAllShields()
                    }
                } else {
                    // If no lastBlockTime is set but blocking is active, set it now
                    sharedDefaults.set(Date(), forKey: "lastBlockTime")
                }
            }
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

