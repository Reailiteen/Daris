import Foundation

/// Statistics for a completed focus session
struct SessionStatistic: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let completedSuccessfully: Bool
    let blockedAppsCount: Int
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        completedSuccessfully: Bool,
        blockedAppsCount: Int
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.completedSuccessfully = completedSuccessfully
        self.blockedAppsCount = blockedAppsCount
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return remainingMinutes > 0 ? "\(hours)h \(remainingMinutes)m" : "\(hours)h"
        }
        return "\(minutes) min"
    }
}

/// Aggregated statistics for a time period
struct PeriodStats {
    let sessions: [SessionStatistic]
    
    var totalSessions: Int {
        sessions.count
    }
    
    var completedSessions: Int {
        sessions.filter { $0.completedSuccessfully }.count
    }
    
    var totalFocusTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    var averageSessionDuration: TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        return totalFocusTime / Double(sessions.count)
    }
    
    var completionRate: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }
    
    var formattedTotalTime: String {
        let totalMinutes = Int(totalFocusTime) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        }
        return "\(minutes)m"
    }
    
    var formattedAverageTime: String {
        let minutes = Int(averageSessionDuration) / 60
        return "\(minutes) min"
    }
}

/// Daily usage data for charts
struct DailyUsage: Identifiable {
    let id = UUID()
    let date: Date
    let focusMinutes: Int
    let sessionsCount: Int
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
}

/// App usage data during sessions
struct AppUsageData: Identifiable, Codable {
    let id: UUID
    let appName: String
    let blockedAttempts: Int
    let date: Date
    
    init(id: UUID = UUID(), appName: String, blockedAttempts: Int, date: Date = Date()) {
        self.id = id
        self.appName = appName
        self.blockedAttempts = blockedAttempts
        self.date = date
    }
}
