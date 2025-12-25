import Foundation

/// Represents a focus session with blocking configuration
struct FocusSession: Identifiable, Codable {
    let id: UUID
    var duration: TimeInterval // in seconds
    var breakDuration: TimeInterval // in seconds, 0 if no breaks
    var breakInterval: TimeInterval // time between breaks
    var startTime: Date?
    var endTime: Date?
    var isActive: Bool
    var completedSuccessfully: Bool
    
    init(
        id: UUID = UUID(),
        duration: TimeInterval,
        breakDuration: TimeInterval = 0,
        breakInterval: TimeInterval = 0,
        startTime: Date? = nil,
        endTime: Date? = nil,
        isActive: Bool = false,
        completedSuccessfully: Bool = false
    ) {
        self.id = id
        self.duration = duration
        self.breakDuration = breakDuration
        self.breakInterval = breakInterval
        self.startTime = startTime
        self.endTime = endTime
        self.isActive = isActive
        self.completedSuccessfully = completedSuccessfully
    }
    
    /// Remaining time in the session
    var remainingTime: TimeInterval {
        guard let startTime = startTime, isActive else { return duration }
        let elapsed = Date().timeIntervalSince(startTime)
        return max(0, duration - elapsed)
    }
    
    /// Progress as a percentage (0.0 to 1.0)
    var progress: Double {
        guard duration > 0 else { return 0 }
        return 1.0 - (remainingTime / duration)
    }
    
    /// Formatted duration string
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
        return "\(minutes) min"
    }
    
    /// Formatted remaining time string
    var formattedRemainingTime: String {
        let totalSeconds = Int(remainingTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/// Preset durations for quick selection
enum SessionDuration: CaseIterable {
    case fifteen
    case thirty
    case fortyfive
    case sixty
    case ninety
    case onetwenty
    case oneeighty
    
    var minutes: Int {
        switch self {
        case .fifteen: return 15
        case .thirty: return 30
        case .fortyfive: return 45
        case .sixty: return 60
        case .ninety: return 90
        case .onetwenty: return 120
        case .oneeighty: return 180
        }
    }
    
    var seconds: TimeInterval {
        return TimeInterval(minutes * 60)
    }
    
    var displayName: String {
        switch self {
        case .fifteen: return "15 min"
        case .thirty: return "30 min"
        case .fortyfive: return "45 min"
        case .sixty: return "1 hour"
        case .ninety: return "1.5 hours"
        case .onetwenty: return "2 hours"
        case .oneeighty: return "3 hours"
        }
    }
}
