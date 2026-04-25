import Foundation

struct UserProfile: Codable {
    var name: String
    var age: Int
    var gender: String
    var wakeUpTime: Date
    var bedtime: Date
    var sleepGoalHours: Double
    var notificationsEnabled: Bool
    var sleepReminderTime: Date?
    var smartAlarmEnabled: Bool
    var smartAlarmWindow: Int
    var healthKitEnabled: Bool
    var darkModeEnabled: Bool
    var premiumActive: Bool

    static var `default`: UserProfile {
        UserProfile(
            name: "",
            age: 30,
            gender: "",
            wakeUpTime: Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!,
            bedtime: Calendar.current.date(from: DateComponents(hour: 23, minute: 0))!,
            sleepGoalHours: 8.0,
            notificationsEnabled: true,
            sleepReminderTime: Calendar.current.date(from: DateComponents(hour: 22, minute: 30))!,
            smartAlarmEnabled: false,
            smartAlarmWindow: 30,
            healthKitEnabled: false,
            darkModeEnabled: true,
            premiumActive: false
        )
    }
}

struct SleepCycle: Codable, Identifiable {
    let id: UUID
    var startTime: Date
    var endTime: Date
    var cycleType: CycleType
    var quality: Int

    enum CycleType: String, Codable {
        case deep = "Deep"
        case light = "Light"
        case rem = "REM"
        case awake = "Awake"
    }

    var durationMinutes: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }
}

struct SmartAlarm {
    var isEnabled: Bool
    var targetTime: Date
    var windowMinutes: Int
    var gentleWakeEnabled: Bool
    var snoozeDuration: Int

    static var `default`: SmartAlarm {
        SmartAlarm(
            isEnabled: false,
            targetTime: Calendar.current.date(from: DateComponents(hour: 7, minute: 0))!,
            windowMinutes: 30,
            gentleWakeEnabled: true,
            snoozeDuration: 9
        )
    }
}

struct BedtimeHabit: Codable, Identifiable {
    let id: UUID
    var name: String
    var duration: Int
    var reminderTime: Date
    var isEnabled: Bool
    var completedToday: Bool

    var formattedDuration: String {
        if duration >= 60 {
            return "\(duration / 60)h \(duration % 60)m"
        }
        return "\(duration)m"
    }
}

struct WeeklySleepReport {
    let weekStartDate: Date
    let averageSleep: Double
    let averageQuality: Int
    let bestNight: Date?
    let worstNight: Date?
    let totalNights: Int
    let improvement: Double
    let insights: [String]
}

struct MonthlySleepReport {
    let month: Date
    let averageSleep: Double
    let averageQuality: Double
    let totalNights: Int
    let bestNight: Date?
    let sleepStreak: Int
    let trend: String
}