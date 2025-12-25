import Foundation

/// Represents a website that can be blocked during focus sessions
struct BlockedWebsite: Identifiable, Codable, Hashable {
    let id: UUID
    var domain: String        // e.g., "twitter.com", "facebook.com"
    var displayName: String   // user-friendly name
    var iconName: String      // SF Symbol name
    var isEnabled: Bool       // toggle individual sites on/off
    var category: WebsiteCategory
    
    init(
        id: UUID = UUID(),
        domain: String,
        displayName: String,
        iconName: String = "globe",
        isEnabled: Bool = true,
        category: WebsiteCategory = .other
    ) {
        self.id = id
        self.domain = domain.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        self.displayName = displayName
        self.iconName = iconName
        self.isEnabled = isEnabled
        self.category = category
    }
    
    /// Formatted domain for display (removes www. prefix)
    var formattedDomain: String {
        domain.hasPrefix("www.") ? String(domain.dropFirst(4)) : domain
    }
}

/// Categories for organizing blocked websites
enum WebsiteCategory: String, CaseIterable, Codable {
    case social = "Social Media"
    case news = "News"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case gaming = "Gaming"
    case other = "Other"
    
    /// SF Symbol icon for the category
    var iconName: String {
        switch self {
        case .social: return "bubble.left.and.bubble.right.fill"
        case .news: return "newspaper.fill"
        case .entertainment: return "play.tv.fill"
        case .shopping: return "cart.fill"
        case .gaming: return "gamecontroller.fill"
        case .other: return "globe"
        }
    }
    
    /// Color associated with the category
    var colorName: String {
        switch self {
        case .social: return "AccentPurple"
        case .news: return "AccentBlue"
        case .entertainment: return "AccentTeal"
        case .shopping: return "AccentPurple"
        case .gaming: return "AccentBlue"
        case .other: return "AccentTeal"
        }
    }
}

/// Preset popular websites for quick selection
struct PresetWebsite {
    let domain: String
    let displayName: String
    let iconName: String
    let category: WebsiteCategory
    
    func toBlockedWebsite() -> BlockedWebsite {
        BlockedWebsite(
            domain: domain,
            displayName: displayName,
            iconName: iconName,
            isEnabled: true,
            category: category
        )
    }
    
    // MARK: - Popular Presets
    
    static let allPresets: [PresetWebsite] = [
        // Social Media
        PresetWebsite(domain: "twitter.com", displayName: "Twitter/X", iconName: "at.circle.fill", category: .social),
        PresetWebsite(domain: "x.com", displayName: "X", iconName: "at.circle.fill", category: .social),
        PresetWebsite(domain: "facebook.com", displayName: "Facebook", iconName: "person.2.fill", category: .social),
        PresetWebsite(domain: "instagram.com", displayName: "Instagram", iconName: "camera.fill", category: .social),
        PresetWebsite(domain: "tiktok.com", displayName: "TikTok", iconName: "play.circle.fill", category: .social),
        PresetWebsite(domain: "snapchat.com", displayName: "Snapchat", iconName: "message.fill", category: .social),
        PresetWebsite(domain: "linkedin.com", displayName: "LinkedIn", iconName: "briefcase.fill", category: .social),
        PresetWebsite(domain: "reddit.com", displayName: "Reddit", iconName: "text.bubble.fill", category: .social),
        PresetWebsite(domain: "pinterest.com", displayName: "Pinterest", iconName: "pin.fill", category: .social),
        PresetWebsite(domain: "tumblr.com", displayName: "Tumblr", iconName: "t.circle.fill", category: .social),
        
        // News
        PresetWebsite(domain: "cnn.com", displayName: "CNN", iconName: "newspaper.fill", category: .news),
        PresetWebsite(domain: "bbc.com", displayName: "BBC", iconName: "newspaper.fill", category: .news),
        PresetWebsite(domain: "nytimes.com", displayName: "NY Times", iconName: "newspaper.fill", category: .news),
        PresetWebsite(domain: "washingtonpost.com", displayName: "Washington Post", iconName: "newspaper.fill", category: .news),
        PresetWebsite(domain: "theguardian.com", displayName: "The Guardian", iconName: "newspaper.fill", category: .news),
        PresetWebsite(domain: "news.google.com", displayName: "Google News", iconName: "newspaper.fill", category: .news),
        
        // Entertainment
        PresetWebsite(domain: "youtube.com", displayName: "YouTube", iconName: "play.rectangle.fill", category: .entertainment),
        PresetWebsite(domain: "netflix.com", displayName: "Netflix", iconName: "play.tv.fill", category: .entertainment),
        PresetWebsite(domain: "twitch.tv", displayName: "Twitch", iconName: "video.fill", category: .entertainment),
        PresetWebsite(domain: "hulu.com", displayName: "Hulu", iconName: "play.tv.fill", category: .entertainment),
        PresetWebsite(domain: "disneyplus.com", displayName: "Disney+", iconName: "play.tv.fill", category: .entertainment),
        PresetWebsite(domain: "spotify.com", displayName: "Spotify", iconName: "music.note", category: .entertainment),
        PresetWebsite(domain: "vimeo.com", displayName: "Vimeo", iconName: "play.rectangle.fill", category: .entertainment),
        
        // Shopping
        PresetWebsite(domain: "amazon.com", displayName: "Amazon", iconName: "cart.fill", category: .shopping),
        PresetWebsite(domain: "ebay.com", displayName: "eBay", iconName: "cart.fill", category: .shopping),
        PresetWebsite(domain: "etsy.com", displayName: "Etsy", iconName: "bag.fill", category: .shopping),
        PresetWebsite(domain: "aliexpress.com", displayName: "AliExpress", iconName: "cart.fill", category: .shopping),
        PresetWebsite(domain: "wish.com", displayName: "Wish", iconName: "bag.fill", category: .shopping),
        
        // Gaming
        PresetWebsite(domain: "steam.com", displayName: "Steam", iconName: "gamecontroller.fill", category: .gaming),
        PresetWebsite(domain: "steampowered.com", displayName: "Steam", iconName: "gamecontroller.fill", category: .gaming),
        PresetWebsite(domain: "epicgames.com", displayName: "Epic Games", iconName: "gamecontroller.fill", category: .gaming),
        PresetWebsite(domain: "roblox.com", displayName: "Roblox", iconName: "gamecontroller.fill", category: .gaming),
        PresetWebsite(domain: "discord.com", displayName: "Discord", iconName: "message.circle.fill", category: .gaming),
    ]
    
    static func presets(for category: WebsiteCategory) -> [PresetWebsite] {
        allPresets.filter { $0.category == category }
    }
}
