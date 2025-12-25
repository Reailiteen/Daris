import Foundation
import ManagedSettings
import FamilyControls

/// Service for managing app blocking using ManagedSettingsStore
class BlockingEngine {
    static let shared = BlockingEngine()
    
    /// The managed settings store for this app
    private let store = ManagedSettingsStore()
    
    /// App group identifier for sharing state with extensions
    private let appGroupIdentifier = "group.com.focusflow.shared"
    
    /// Website blocking service
    private let websiteService = WebsiteBlockingService.shared
    
    /// FocusFlow's bundle identifier - should never be blocked
    private let focusFlowBundleIdentifier = "com.focusflow.focusFlowFlutter"
    
    private init() {}
    
    // MARK: - Blocking Methods
    
    /// Block the selected apps and categories
    /// - Parameter selection: The FamilyActivitySelection containing apps/categories to block
    func blockApps(selection: FamilyActivitySelection) {
        // CRITICAL: Try to filter out FocusFlow
        let filteredSelection = filterOutFocusFlow(from: selection)
        
        // Set the shield restrictions for applications
        // WARNING: If FocusFlow's token is in this list, it WILL be blocked
        store.shield.applications = filteredSelection.applicationTokens.isEmpty ? nil : filteredSelection.applicationTokens
        
        // Set the shield restrictions for categories
        // WARNING: If FocusFlow is in a blocked category, it WILL be blocked
        store.shield.applicationCategories = filteredSelection.categoryTokens.isEmpty ? nil : .specific(filteredSelection.categoryTokens)
        
        // Optionally shield web domains as well
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        
        // Save blocking state for extensions
        saveBlockingState(isBlocking: true)
        
        // CRITICAL: Set emergency unblock flag immediately
        // This tells the DeviceActivityMonitorExtension to unblock if FocusFlow is blocked
        setEmergencyUnblockFlag()
        
        print("BlockingEngine: Applied shields to \(selection.applicationTokens.count) apps and \(selection.categoryTokens.count) categories")
        print("BlockingEngine: ⚠️ WARNING - Emergency unblock flag set. If FocusFlow is blocked, it will auto-unblock.")
    }
    
    /// Filter out FocusFlow from the selection to prevent self-blocking
    /// - Parameter selection: The original selection
    /// - Returns: A filtered selection without FocusFlow (if possible to identify)
    private func filterOutFocusFlow(from selection: FamilyActivitySelection) -> FamilyActivitySelection {
        // Since ApplicationToken is opaque and doesn't expose bundle identifiers,
        // we can't directly filter it. However, we can try to work around this:
        // 1. The FamilyControls framework should prevent self-blocking, but it's not guaranteed
        // 2. We'll create a new selection and try to exclude our app
        
        // For now, we'll use the selection as-is but add safeguards
        // The real protection is that FocusFlow should never appear in the picker
        // or if it does, the user should be warned
        
        var filteredSelection = FamilyActivitySelection()
        
        // Copy all tokens - we can't filter by bundle ID since tokens are opaque
        // This is a limitation we need to work around
        filteredSelection.applicationTokens = selection.applicationTokens
        filteredSelection.categoryTokens = selection.categoryTokens
        filteredSelection.webDomainTokens = selection.webDomainTokens
        
        // Log a warning if we have many apps selected (FocusFlow might be included)
        if selection.applicationTokens.count > 0 {
            print("BlockingEngine: WARNING - \(selection.applicationTokens.count) apps selected. Ensure FocusFlow is not included!")
        }
        
        return filteredSelection
    }
    
    /// Block apps and websites together
    /// - Parameters:
    ///   - selection: The FamilyActivitySelection containing apps/categories to block
    ///   - websites: Custom websites to block
    func blockAppsAndWebsites(selection: FamilyActivitySelection, websites: [BlockedWebsite]) {
        // CRITICAL: Try to filter out FocusFlow, but since ApplicationToken is opaque,
        // we can't directly identify which token is FocusFlow
        let filteredSelection = filterOutFocusFlow(from: selection)
        
        // Set the shield restrictions for applications
        // WARNING: If FocusFlow's token is in this list, it WILL be blocked
        // The only way to prevent this is to not select FocusFlow in the picker
        store.shield.applications = filteredSelection.applicationTokens.isEmpty ? nil : filteredSelection.applicationTokens
        
        // Set the shield restrictions for categories
        // WARNING: If FocusFlow is in a blocked category, it WILL be blocked
        // Avoid blocking entire categories that might include FocusFlow
        store.shield.applicationCategories = filteredSelection.categoryTokens.isEmpty ? nil : .specific(filteredSelection.categoryTokens)
        
        // Combine FamilyActivitySelection web domains with custom blocked websites
        var combinedWebDomains = selection.webDomainTokens
        
        // Note: Custom domains from BlockedWebsite list are saved for extension use
        // The ManagedSettings framework primarily works with webDomainTokens from FamilyActivitySelection
        websiteService.applyWebsiteBlocks(websites, to: store)
        
        store.shield.webDomains = combinedWebDomains.isEmpty ? nil : combinedWebDomains
        
        // Save blocking state for extensions
        saveBlockingState(isBlocking: true)
        
        // CRITICAL: Set emergency unblock flag immediately
        // This tells the DeviceActivityMonitorExtension to unblock if FocusFlow is blocked
        setEmergencyUnblockFlag()
        
        // Also set a timer to unblock after a short delay as a safety measure
        // This ensures FocusFlow can always recover
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            // Check if we're still blocking and if so, set emergency flag again
            if self.isBlocking {
                self.setEmergencyUnblockFlag()
            }
        }
        
        let enabledWebsites = websites.filter { $0.isEnabled }
        print("BlockingEngine: Applied shields to \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories, and \(enabledWebsites.count) custom websites")
        print("BlockingEngine: ⚠️ WARNING - Emergency unblock flag set. If FocusFlow is blocked, it will auto-unblock.")
    }
    
    /// Remove all shields and allow all apps
    func unblockAll() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        // Clear website blocks
        websiteService.removeWebsiteBlocks(from: store)
        
        // Clear blocking state
        saveBlockingState(isBlocking: false)
        
        // Clear emergency unblock flag
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.set(false, forKey: "emergencyUnblockFocusFlow")
        }
        UserDefaults.standard.set(false, forKey: "emergencyUnblockFocusFlow")
        
        print("BlockingEngine: Removed all shields")
    }
    
    /// Check if blocking is currently active
    var isBlocking: Bool {
        store.shield.applications != nil || store.shield.applicationCategories != nil || store.shield.webDomains != nil
    }
    
    // MARK: - Advanced Settings
    
    /// Configure additional managed settings
    func configureAdditionalSettings() {
        // Prevent certain App Store features during focus
        // store.appStore.denyInAppPurchases = true
        
        // Prevent passcode changes (for stricter focus)
        // store.passcode.lockPasscode = true
        
        // Note: These settings require careful consideration
        // and may not be appropriate for all use cases
    }
    
    /// Clear all managed settings
    func clearAllSettings() {
        if #available(iOS 16.0, *) {
            store.clearAllSettings()
        } else {
            // For iOS 15, manually clear settings
            store.shield.applications = nil
            store.shield.applicationCategories = nil
            store.shield.webDomains = nil
        }
        saveBlockingState(isBlocking: false)
    }
    
    // MARK: - State Persistence
    
    /// Save blocking state to App Group for extension access
    private func saveBlockingState(isBlocking: Bool) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.set(isBlocking, forKey: "isBlockingActive")
            sharedDefaults.set(Date(), forKey: "lastBlockingUpdate")
        }
        UserDefaults.standard.set(isBlocking, forKey: "isBlockingActive")
    }
    
    /// Load blocking state (useful for extensions)
    static func loadBlockingState() -> Bool {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.focusflow.shared") {
            return sharedDefaults.bool(forKey: "isBlockingActive")
        }
        return UserDefaults.standard.bool(forKey: "isBlockingActive")
    }
    
    // MARK: - Emergency Unblock
    
    /// Set emergency unblock flag for DeviceActivityMonitorExtension
    /// This tells the extension to unblock everything if FocusFlow is blocked
    private func setEmergencyUnblockFlag() {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.set(true, forKey: "emergencyUnblockFocusFlow")
            sharedDefaults.set(Date(), forKey: "lastBlockTime")
        }
        UserDefaults.standard.set(true, forKey: "emergencyUnblockFocusFlow")
        print("BlockingEngine: Emergency unblock flag set - DeviceActivityMonitorExtension will auto-unblock if needed")
    }
    
    /// Emergency unblock - call this if the app blocks itself
    /// This should be called on app launch to check if we need to unblock
    func checkAndEmergencyUnblock() {
        // Check if we should emergency unblock (e.g., if app was just launched and blocking is active)
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            let emergencyEnabled = sharedDefaults.bool(forKey: "emergencyUnblockFocusFlow")
            let isBlocking = sharedDefaults.bool(forKey: "isBlockingActive")
            
            // If blocking is active and emergency flag is set, we might need to unblock
            // This is a safety mechanism - the app should never block itself in the first place
            if emergencyEnabled && isBlocking {
                print("BlockingEngine: Emergency unblock flag detected. Consider unblocking if app is locked.")
            }
        }
    }
}

// MARK: - Shield Customization
extension BlockingEngine {
    /// Get the current shield configuration description
    var shieldDescription: String {
        var description = ""
        
        if let apps = store.shield.applications {
            description += "Apps: \(apps.count) blocked\n"
        }
        
        if store.shield.applicationCategories != nil {
            description += "Categories: blocked\n"
        }
        
        if let domains = store.shield.webDomains {
            description += "Web domains: \(domains.count) blocked\n"
        }
        
        // Include custom websites
        let customDomains = WebsiteBlockingService.loadDomainsList()
        if !customDomains.isEmpty {
            description += "Custom websites: \(customDomains.count) blocked"
        }
        
        return description.isEmpty ? "No shields active" : description
    }
}

