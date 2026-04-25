import Foundation
import Combine

final class SleepHistoryViewModel: ObservableObject {
    @Published var records: [SleepRecord] = []
    @Published var selectedRecord: SleepRecord?
    @Published var filterPeriod: FilterPeriod = .week

    private let dataService = DataService.shared

    enum FilterPeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All"
    }

    var filteredRecords: [SleepRecord] {
        let calendar = Calendar.current
        let now = Date()

        switch filterPeriod {
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now)!
            return records.filter { $0.date >= start }
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: now)!
            return records.filter { $0.date >= start }
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: now)!
            return records.filter { $0.date >= start }
        case .all:
            return records
        }
    }

    var averageSleep: Double {
        guard !filteredRecords.isEmpty else { return 0 }
        let total = filteredRecords.reduce(0) { $0 + $1.totalSleepMinutes }
        return Double(total) / Double(filteredRecords.count) / 60.0
    }

    var averageQuality: Int {
        guard !filteredRecords.isEmpty else { return 0 }
        let total = filteredRecords.reduce(0) { $0 + $1.qualityScore }
        return total / filteredRecords.count
    }

    var bestNight: SleepRecord? {
        filteredRecords.max(by: { $0.qualityScore < $1.qualityScore })
    }

    var worstNight: SleepRecord? {
        filteredRecords.min(by: { $0.qualityScore < $1.qualityScore })
    }

    func loadRecords() {
        records = dataService.sleepRecords
    }

    func deleteRecord(at index: Int) {
        let record = filteredRecords[index]
        if let originalIndex = records.firstIndex(where: { $0.id == record.id }) {
            dataService.deleteSleepRecord(at: originalIndex)
            loadRecords()
        }
    }

    func exportData() -> String {
        var csv = "Date,Bedtime,WakeTime,Hours,Quality,Deep,Light,REM,Awake\n"

        for record in filteredRecords {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"

            csv += "\(formatter.string(from: record.date)),"
            csv += "\(timeFormatter.string(from: record.bedtime)),"
            csv += "\(timeFormatter.string(from: record.wakeTime)),"
            csv += String(format: "%.1f,", record.totalHours)
            csv += "\(record.qualityScore),"
            csv += "\(record.deepSleepMinutes),"
            csv += "\(record.lightSleepMinutes),"
            csv += "\(record.remSleepMinutes),"
            csv += "\(record.awakeMinutes)\n"
        }

        return csv
    }
}