import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var sleepGoal: SleepGoal
    @Published var smartAlarm: SmartAlarm
    @Published var bedtimeHabits: [BedtimeHabit] = []

    private let dataService = DataService.shared

    init() {
        userProfile = dataService.userProfile
        sleepGoal = dataService.sleepGoal
        smartAlarm = dataService.smartAlarm
        bedtimeHabits = dataService.bedtimeHabits
    }

    var isDarkMode: Bool {
        get { ThemeService.shared.isDarkMode }
        set {
            ThemeService.shared.isDarkMode = newValue
            objectWillChange.send()
        }
    }

    var isPremium: Bool {
        SubscriptionService.shared.isPremium
    }

    func saveProfile() {
        dataService.updateUserProfile(userProfile)
    }

    func saveSleepGoal() {
        dataService.updateSleepGoal(sleepGoal)
    }

    func saveSmartAlarm() {
        dataService.smartAlarm = smartAlarm
        dataService.saveData()
    }

    func addBedtimeHabit(_ habit: BedtimeHabit) {
        dataService.addBedtimeHabit(habit)
        bedtimeHabits = dataService.bedtimeHabits
    }

    func toggleHabit(_ habit: BedtimeHabit) {
        dataService.toggleHabitCompletion(habit)
        bedtimeHabits = dataService.bedtimeHabits
    }

    func enableHealthKit() async {
        do {
            try await HealthKitService.shared.requestAuthorization()
            userProfile.healthKitEnabled = true
            saveProfile()
        } catch {
            print("HealthKit authorization failed: \(error)")
        }
    }

    func scheduleBedtimeReminder() {
        if sleepGoal.reminderEnabled, let time = sleepGoal.reminderTime {
            NotificationService.shared.scheduleBedtimeReminder(at: time)
        } else {
            NotificationService.shared.cancelNotification(identifier: "bedtime_reminder")
        }
    }
}