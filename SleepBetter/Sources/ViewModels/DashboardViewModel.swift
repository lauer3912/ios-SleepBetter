import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var todaySleep: SleepRecord?
    @Published var weeklyStats: SleepStats?
    @Published var bedtimeReminder: Date?
    @Published var currentAudio: SleepAudio?
    @Published var isPlayingAudio: Bool = false

    private let dataService = DataService.shared

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good Morning"
        } else if hour < 17 {
            return "Good Afternoon"
        } else if hour < 21 {
            return "Good Evening"
        } else {
            return "Good Night"
        }
    }

    var sleepQualityText: String {
        guard let record = todaySleep else { return "No data" }
        switch record.qualityScore {
        case 0..<50: return "Poor"
        case 50..<70: return "Fair"
        case 70..<85: return "Good"
        default: return "Excellent"
        }
    }

    var sleepProgress: Double {
        guard let record = todaySleep else { return 0 }
        let goalHours = dataService.sleepGoal.targetHours
        return min(record.totalHours / goalHours, 1.0)
    }

    var recentRecords: [SleepRecord] {
        Array(dataService.sleepRecords.prefix(7))
    }

    var insights: [SleepInsight] {
        var result: [SleepInsight] = []

        if let record = todaySleep {
            if record.deepSleepMinutes < 90 {
                result.append(SleepInsight(
                    title: "Increase Deep Sleep",
                    description: "You had \(record.deepSleepMinutes) min of deep sleep. Aim for 90-120 min.",
                    icon: "moon.zzz.fill",
                    actionType: .playAudio
                ))
            }

            if record.awakeMinutes > 30 {
                result.append(SleepInsight(
                    title: "Reduce Night Wakings",
                    description: "You were awake for \(record.awakeMinutes) min during the night.",
                    icon: "exclamationmark.triangle.fill",
                    actionType: .openSettings
                ))
            }
        }

        result.append(SleepInsight(
            title: "Consistent Schedule",
            description: "Going to bed at the same time improves sleep quality.",
            icon: "clock.fill",
            actionType: .setReminder
        ))

        return result
    }

    func refreshData() {
        let today = Calendar.current.startOfDay(for: Date())
        todaySleep = dataService.sleepRecords.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
        weeklyStats = dataService.getStats(for: .week)
        bedtimeReminder = dataService.sleepGoal.reminderTime
    }

    func getAvailableAudios() -> [SleepAudio] {
        return [
            SleepAudio(id: UUID(), name: "Rain", category: .nature, fileName: "rain", duration: 3600),
            SleepAudio(id: UUID(), name: "Ocean Waves", category: .nature, fileName: "ocean", duration: 3600),
            SleepAudio(id: UUID(), name: "Forest", category: .nature, fileName: "forest", duration: 3600),
            SleepAudio(id: UUID(), name: "White Noise", category: .whiteNoise, fileName: "white_noise", duration: 3600),
            SleepAudio(id: UUID(), name: "Fan", category: .whiteNoise, fileName: "fan", duration: 3600),
            SleepAudio(id: UUID(), name: "Pink Noise", category: .whiteNoise, fileName: "pink_noise", duration: 3600),
            SleepAudio(id: UUID(), name: "Meditation", category: .meditation, fileName: "meditation", duration: 1200),
            SleepAudio(id: UUID(), name: "Deep Breathing", category: .meditation, fileName: "breathing", duration: 900),
            SleepAudio(id: UUID(), name: "Bedroom Ambience", category: .ambient, fileName: "bedroom", duration: 3600),
            SleepAudio(id: UUID(), name: "Fireplace", category: .ambient, fileName: "fireplace", duration: 3600)
        ]
    }
}