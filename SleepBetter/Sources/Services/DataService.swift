import Foundation

final class DataService {
    static let shared = DataService()

    private let sleepRecordsKey = "sleep_records"
    private let userProfileKey = "user_profile"
    private let sleepGoalKey = "sleep_goal"
    private let bedtimeHabitsKey = "bedtime_habits"
    private let smartAlarmKey = "smart_alarm"

    private init() {
        loadData()
    }

    var sleepRecords: [SleepRecord] = []
    var userProfile: UserProfile = .default
    var sleepGoal: SleepGoal = SleepGoal(targetHours: 8, targetBedtime: "23:00", targetWakeTime: "07:00", reminderEnabled: true, reminderTime: nil)
    var bedtimeHabits: [BedtimeHabit] = []
    var smartAlarm: SmartAlarm = .default

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: sleepRecordsKey),
           let records = try? JSONDecoder().decode([SleepRecord].self, from: data) {
            sleepRecords = records
        }

        if let data = UserDefaults.standard.data(forKey: userProfileKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }

        if let data = UserDefaults.standard.data(forKey: sleepGoalKey),
           let goal = try? JSONDecoder().decode(SleepGoal.self, from: data) {
            sleepGoal = goal
        }

        if let data = UserDefaults.standard.data(forKey: bedtimeHabitsKey),
           let habits = try? JSONDecoder().decode([BedtimeHabit].self, from: data) {
            bedtimeHabits = habits
        }

        if let data = UserDefaults.standard.data(forKey: smartAlarmKey),
           let alarm = try? JSONDecoder().decode(SmartAlarm.self, from: data) {
            smartAlarm = alarm
        }
    }

    func saveData() {
        if let data = try? JSONEncoder().encode(sleepRecords) {
            UserDefaults.standard.set(data, forKey: sleepRecordsKey)
        }

        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: userProfileKey)
        }

        if let data = try? JSONEncoder().encode(sleepGoal) {
            UserDefaults.standard.set(data, forKey: sleepGoalKey)
        }

        if let data = try? JSONEncoder().encode(bedtimeHabits) {
            UserDefaults.standard.set(data, forKey: bedtimeHabitsKey)
        }

        if let data = try? JSONEncoder().encode(smartAlarm) {
            UserDefaults.standard.set(data, forKey: smartAlarmKey)
        }
    }

    func addSleepRecord(_ record: SleepRecord) {
        sleepRecords.insert(record, at: 0)
        saveData()
    }

    func deleteSleepRecord(at index: Int) {
        guard index < sleepRecords.count else { return }
        sleepRecords.remove(at: index)
        saveData()
    }

    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveData()
    }

    func updateSleepGoal(_ goal: SleepGoal) {
        sleepGoal = goal
        saveData()
    }

    func addBedtimeHabit(_ habit: BedtimeHabit) {
        bedtimeHabits.append(habit)
        saveData()
    }

    func toggleHabitCompletion(_ habit: BedtimeHabit) {
        if let index = bedtimeHabits.firstIndex(where: { $0.id == habit.id }) {
            bedtimeHabits[index].completedToday.toggle()
            saveData()
        }
    }

    func getStats(for period: StatsPeriod) -> SleepStats {
        let calendar = Calendar.current
        let now = Date()
        var startDate: Date

        switch period {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .month:
            startDate = calendar.date(byAdding: .day, value: -30, to: now)!
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        }

        let filteredRecords = sleepRecords.filter { $0.date >= startDate }

        guard !filteredRecords.isEmpty else {
            return SleepStats(averageSleep: 0, averageQuality: 0, totalNights: 0, bestNight: nil, worstNight: nil, weeklyTrend: [], monthlyTrend: [])
        }

        let totalSleep = filteredRecords.reduce(0) { $0 + $1.totalSleepMinutes }
        let totalQuality = filteredRecords.reduce(0) { $0 + $1.qualityScore }

        let avgSleep = Double(totalSleep) / Double(filteredRecords.count) / 60.0
        let avgQuality = Double(totalQuality) / Double(filteredRecords.count)

        let sorted = filteredRecords.sorted { $0.qualityScore > $1.qualityScore }

        return SleepStats(
            averageSleep: avgSleep,
            averageQuality: avgQuality,
            totalNights: filteredRecords.count,
            bestNight: sorted.first,
            worstNight: sorted.last,
            weeklyTrend: calculateWeeklyTrend(),
            monthlyTrend: calculateMonthlyTrend()
        )
    }

    private func calculateWeeklyTrend() -> [Double] {
        let calendar = Calendar.current
        var trend: [Double] = []

        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayRecords = sleepRecords.filter { calendar.isDate($0.date, inSameDayAs: dayStart) }

            if let record = dayRecords.first {
                trend.append(record.totalHours)
            } else {
                trend.append(0)
            }
        }

        return trend.reversed()
    }

    private func calculateMonthlyTrend() -> [Double] {
        let calendar = Calendar.current
        var trend: [Double] = []

        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayRecords = sleepRecords.filter { calendar.isDate($0.date, inSameDayAs: dayStart) }

            if let record = dayRecords.first {
                trend.append(record.totalHours)
            } else {
                trend.append(0)
            }
        }

        return trend.reversed()
    }

    enum StatsPeriod {
        case week
        case month
        case year
    }
}