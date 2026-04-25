import UIKit
import SnapKit

final class SettingsViewController: UIViewController {

    private let viewModel = SettingsViewModel()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = UIColor.backgroundColor
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tv.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        return tv
    }()

    private enum Section: Int, CaseIterable {
        case profile
        case sleepGoal
        case alarms
        case appearance
        case subscription
        case about
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    private func setupUI() {
        title = "Settings"
        view.backgroundColor = UIColor.backgroundColor

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .profile: return 3
        case .sleepGoal: return 2
        case .alarms: return 3
        case .appearance: return 2
        case .subscription: return 2
        case .about: return 3
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .profile: return "Profile"
        case .sleepGoal: return "Sleep Goal"
        case .alarms: return "Alarms"
        case .appearance: return "Appearance"
        case .subscription: return "Subscription"
        case .about: return "About"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!

        switch section {
        case .profile:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            var config = cell.defaultContentConfiguration()
            switch indexPath.row {
            case 0:
                config.text = "Name"
                config.secondaryText = viewModel.userProfile.name.isEmpty ? "Not set" : viewModel.userProfile.name
            case 1:
                config.text = "Age"
                config.secondaryText = "\(viewModel.userProfile.age)"
            case 2:
                config.text = "HealthKit"
                config.secondaryText = viewModel.userProfile.healthKitEnabled ? "Connected" : "Not connected"
            default: break
            }
            cell.contentConfiguration = config
            return cell

        case .sleepGoal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            var config = cell.defaultContentConfiguration()
            switch indexPath.row {
            case 0:
                config.text = "Target Sleep"
                config.secondaryText = "\(viewModel.sleepGoal.targetHours) hours"
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                cell.configure(title: "Bedtime Reminder", isOn: viewModel.sleepGoal.reminderEnabled) { [weak self] isOn in
                    self?.viewModel.sleepGoal.reminderEnabled = isOn
                    self?.viewModel.saveSleepGoal()
                }
                return cell
            default: break
            }
            cell.contentConfiguration = config
            return cell

        case .alarms:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            switch indexPath.row {
            case 0:
                cell.configure(title: "Smart Alarm", isOn: viewModel.smartAlarm.isEnabled) { [weak self] isOn in
                    self?.viewModel.smartAlarm.isEnabled = isOn
                    self?.viewModel.saveSmartAlarm()
                }
            case 1:
                cell.configure(title: "Gentle Wake", isOn: viewModel.smartAlarm.gentleWakeEnabled) { [weak self] isOn in
                    self?.viewModel.smartAlarm.gentleWakeEnabled = isOn
                    self?.viewModel.saveSmartAlarm()
                }
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                var config = cell.defaultContentConfiguration()
                config.text = "Snooze Duration"
                config.secondaryText = "\(viewModel.smartAlarm.snoozeDuration) min"
                cell.contentConfiguration = config
                return cell
            default: break
            }
            return cell

        case .appearance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            switch indexPath.row {
            case 0:
                cell.configure(title: "Dark Mode", isOn: viewModel.isDarkMode) { [weak self] isOn in
                    self?.viewModel.isDarkMode = isOn
                }
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
                cell.accessoryType = .disclosureIndicator
                var config = cell.defaultContentConfiguration()
                config.text = "Theme Color"
                config.secondaryText = "Indigo"
                cell.contentConfiguration = config
                return cell
            default: break
            }
            return cell

        case .subscription:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            var config = cell.defaultContentConfiguration()
            switch indexPath.row {
            case 0:
                config.text = "Premium Status"
                config.secondaryText = viewModel.isPremium ? "Active" : "Free Plan"
            case 1:
                config.text = "Manage Subscription"
            default: break
            }
            cell.contentConfiguration = config
            return cell

        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            cell.accessoryType = .disclosureIndicator
            var config = cell.defaultContentConfiguration()
            switch indexPath.row {
            case 0:
                config.text = "Version"
                config.secondaryText = "1.0.0"
            case 1:
                config.text = "Privacy Policy"
            case 2:
                config.text = "Terms of Service"
            default: break
            }
            cell.contentConfiguration = config
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

final class SwitchCell: UITableViewCell {
    private let switchControl = UISwitch()
    private var onToggle: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, isOn: Bool, onToggle: @escaping (Bool) -> Void) {
        var config = defaultContentConfiguration()
        config.text = title
        contentConfiguration = config

        switchControl.isOn = isOn
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        accessoryView = switchControl
        self.onToggle = onToggle
    }

    @objc private func switchChanged() {
        onToggle?(switchControl.isOn)
    }
}

final class SetAlarmViewController: UIViewController {
    private let datePicker = UIDatePicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set Alarm"
        view.backgroundColor = UIColor.backgroundColor

        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()

        view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
    }

    @objc private func saveTapped() {
        let selectedTime = datePicker.date
        NotificationService.shared.scheduleSmartAlarm(at: selectedTime)

        let alert = UIAlertController(title: "Alarm Set", message: "Your wake-up alarm has been set.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}