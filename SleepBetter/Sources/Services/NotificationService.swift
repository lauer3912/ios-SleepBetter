import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func scheduleBedtimeReminder(at time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Wind Down"
        content.body = "Your target bedtime is approaching. Start your bedtime routine for better sleep."
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(identifier: "bedtime_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleSmartAlarm(at time: Date, identifier: String = "smart_alarm") {
        let content = UNMutableNotificationContent()
        content.title = "Wake Up"
        content.body = "Good morning! Start your day energized."
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleWeeklyReport() {
        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Sleep Report"
        content.body = "Check out how you slept this week and get personalized insights."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "weekly_report", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}