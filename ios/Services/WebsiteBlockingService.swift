import Foundation
import ManagedSettings

/// Service for managing blocked websites with persistence
class WebsiteBlockingService {
    static let shared = WebsiteBlockingService()
    
    /// App group identifier for sharing state with extensions
    private let appGroupIdentifier = "group.com.focusflow.shared"
    
    /// UserDefaults key for blocked websites
    private let blockedWebsitesKey = "blockedWebsites"
    
    private init() {}
    
    // MARK: - Persistence
    
    /// Save blocked websites to UserDefaults
    func saveBlockedWebsites(_ websites: [BlockedWebsite]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(websites)
            
            // Save to both app group and standard defaults
            if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                sharedDefaults.set(data, forKey: blockedWebsitesKey)
            }
            UserDefaults.standard.set(data, forKey: blockedWebsitesKey)
            
            print("WebsiteBlockingService: Saved \(websites.count) blocked websites")
        } catch {
            print("WebsiteBlockingService: Failed to save websites - \(error)")
        }
    }
    
    /// Load blocked websites from UserDefaults
    func loadBlockedWebsites() -> [BlockedWebsite] {
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
        
        guard let data = defaults.data(forKey: blockedWebsitesKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let websites = try decoder.decode([BlockedWebsite].self, from: data)
            print("WebsiteBlockingService: Loaded \(websites.count) blocked websites")
            return websites
        } catch {
            print("WebsiteBlockingService: Failed to load websites - \(error)")
            return []
        }
    }
    
    // MARK: - Domain Validation
    
    /// Validate and format a domain string
    func formatDomain(_ input: String) -> String? {
        var domain = input
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove protocol if present
        if domain.hasPrefix("https://") {
            domain = String(domain.dropFirst(8))
        } else if domain.hasPrefix("http://") {
            domain = String(domain.dropFirst(7))
        }
        
        // Remove www. prefix
        if domain.hasPrefix("www.") {
            domain = String(domain.dropFirst(4))
        }
        
        // Remove trailing path
        if let slashIndex = domain.firstIndex(of: "/") {
            domain = String(domain[..<slashIndex])
        }
        
        // Basic validation
        guard !domain.isEmpty,
              domain.contains("."),
              !domain.contains(" "),
              domain.count >= 4 else {
            return nil
        }
        
        return domain
    }
    
    /// Check if a domain is valid
    func isValidDomain(_ domain: String) -> Bool {
        return formatDomain(domain) != nil
    }
    
    // MARK: - Enabled Websites
    
    /// Get only the enabled websites
    func getEnabledWebsites(_ websites: [BlockedWebsite]) -> [BlockedWebsite] {
        return websites.filter { $0.isEnabled }
    }
    
    /// Get enabled domains as a set of strings
    func getEnabledDomains(_ websites: [BlockedWebsite]) -> Set<String> {
        return Set(getEnabledWebsites(websites).map { $0.domain })
    }
    
    // MARK: - Blocking
    
    /// Apply website blocks using ManagedSettingsStore
    /// Note: For custom domains, we need to use WebDomain tokens
    /// This works alongside the FamilyActivitySelection web domains
    func applyWebsiteBlocks(_ websites: [BlockedWebsite], to store: ManagedSettingsStore) {
        let enabledDomains = getEnabledDomains(websites)
        
        if enabledDomains.isEmpty {
            // Don't override if no custom domains
            print("WebsiteBlockingService: No custom domains to block")
            return
        }
        
        // Note: Custom WebDomain tokens require network extension
        // This is a placeholder for custom domain blocking
        // The actual implementation uses FamilyActivitySelection web domains
        print("WebsiteBlockingService: Ready to block \(enabledDomains.count) domains")
        
        // Save domains for extension access
        saveDomainsList(enabledDomains)
    }
    
    /// Remove all website blocks
    func removeWebsiteBlocks(from store: ManagedSettingsStore) {
        // Clear saved domains
        saveDomainsList([])
        print("WebsiteBlockingService: Removed all website blocks")
    }
    
    /// Save domains list for extension access
    private func saveDomainsList(_ domains: Set<String>) {
        if let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) {
            sharedDefaults.set(Array(domains), forKey: "blockedDomainsList")
            sharedDefaults.set(Date(), forKey: "lastDomainsUpdate")
        }
        UserDefaults.standard.set(Array(domains), forKey: "blockedDomainsList")
    }
    
    /// Load domains list (for extensions)
    static func loadDomainsList() -> [String] {
        if let sharedDefaults = UserDefaults(suiteName: "group.com.focusflow.shared") {
            return sharedDefaults.stringArray(forKey: "blockedDomainsList") ?? []
        }
        return UserDefaults.standard.stringArray(forKey: "blockedDomainsList") ?? []
    }
}
