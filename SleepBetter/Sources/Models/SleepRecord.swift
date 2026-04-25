import Foundation

struct SleepRecord: Codable, Identifiable {
    let id: UUID
    var date: Date
    var bedtime: Date
    var wakeTime: Date
    var deepSleepMinutes: Int
    var lightSleepMinutes: Int
    var remSleepMinutes: Int
    var awakeMinutes: Int
    var qualityScore: Int
    var notes: String
    var audioPlayed: String?
    var alarmType: String?

    var totalSleepMinutes: Int {
        deepSleepMinutes + lightSleepMinutes + remSleepMinutes
    }

    var totalHours: Double {
        Double(totalSleepMinutes) / 60.0
    }

    var formattedDuration: String {
        let hours = totalSleepMinutes / 60
        let minutes = totalSleepMinutes % 60
        return "\(hours)h \(minutes)m"
    }

    static var sample: SleepRecord {
        SleepRecord(
            id: UUID(),
            date: Date(),
            bedtime: Calendar.current.date(byAdding: .hour, value: -8, to: Date())!,
            wakeTime: Date(),
            deepSleepMinutes: 120,
            lightSleepMinutes: 240,
            remSleepMinutes: 90,
            awakeMinutes: 30,
            qualityScore: 85,
            notes: "",
            audioPlayed: nil,
            alarmType: nil
        )
    }
}

struct SleepGoal: Codable {
    var targetHours: Double
    var targetBedtime: String
    var targetWakeTime: String
    var reminderEnabled: Bool
    var reminderTime: Date?
}

struct SleepAudio: Identifiable {
    let id: UUID
    let name: String
    let category: AudioCategory
    let fileName: String
    let duration: Int

    enum AudioCategory: String, CaseIterable {
        case whiteNoise = "White Noise"
        case nature = "Nature"
        case ambient = "Ambient"
        case meditation = "Meditation"
    }
}

struct SleepStats {
    var averageSleep: Double
    var averageQuality: Double
    var totalNights: Int
    var bestNight: SleepRecord?
    var worstNight: SleepRecord?
    var weeklyTrend: [Double]
    var monthlyTrend: [Double]
}

struct SleepInsight {
    let title: String
    let description: String
    let icon: String
    let actionType: InsightAction
}

enum InsightAction {
    case none
    case openSettings
    case playAudio
    case setReminder
}