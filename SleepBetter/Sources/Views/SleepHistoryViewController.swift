import UIKit
import SnapKit
import Combine

final class SleepHistoryViewController: UIViewController {

    private let viewModel = SleepHistoryViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Week", "Month", "Year", "All"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        return control
    }()

    private lazy var summaryCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var avgSleepLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var avgQualityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(SleepRecordCell.self, forCellReuseIdentifier: "SleepRecordCell")
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    private lazy var exportButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(exportTapped))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadRecords()
        tableView.reloadData()
        updateSummary()
    }

    private func setupUI() {
        title = "Sleep History"
        view.backgroundColor = UIColor.backgroundColor
        navigationItem.rightBarButtonItem = exportButton

        view.addSubview(segmentedControl)
        view.addSubview(summaryCard)
        summaryCard.addSubview(avgSleepLabel)
        summaryCard.addSubview(avgQualityLabel)
        view.addSubview(tableView)

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        summaryCard.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }

        avgSleepLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }

        avgQualityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(avgSleepLabel.snp.bottom).offset(4)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(summaryCard.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.$filterPeriod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
                self?.updateSummary()
            }
            .store(in: &cancellables)
    }

    private func updateSummary() {
        avgSleepLabel.text = String(format: "%.1f hours avg", viewModel.averageSleep)
        avgQualityLabel.text = "Quality: \(viewModel.averageQuality)%"
    }

    @objc private func filterChanged() {
        let periods: [SleepHistoryViewModel.FilterPeriod] = [.week, .month, .year, .all]
        viewModel.filterPeriod = periods[segmentedControl.selectedSegmentIndex]
    }

    @objc private func exportTapped() {
        let csv = viewModel.exportData()
        let activityVC = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

extension SleepHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SleepRecordCell", for: indexPath) as! SleepRecordCell
        cell.configure(with: viewModel.filteredRecords[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = SleepDetailViewController()
        detailVC.record = viewModel.filteredRecords[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.viewModel.deleteRecord(at: indexPath.row)
            tableView.reloadData()
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

final class SleepRecordCell: UITableViewCell {
    private let containerView = UIView()
    private let dateLabel = UILabel()
    private let durationLabel = UILabel()
    private let qualityLabel = UILabel()
    private let sleepBarsView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.backgroundColor = UIColor.cardBackground
        containerView.layer.cornerRadius = 12

        containerView.addSubview(dateLabel)
        containerView.addSubview(durationLabel)
        containerView.addSubview(qualityLabel)
        containerView.addSubview(sleepBarsView)

        dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = UIColor.textSecondary

        durationLabel.font = .systemFont(ofSize: 20, weight: .bold)
        durationLabel.textColor = UIColor.textPrimary

        qualityLabel.font = .systemFont(ofSize: 12)
        qualityLabel.textColor = UIColor.successColor

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        }

        dateLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
        }

        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
        }

        qualityLabel.snp.makeConstraints { make in
            make.top.equalTo(durationLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
        }

        sleepBarsView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(40)
        }
    }

    func configure(with record: SleepRecord) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        dateLabel.text = formatter.string(from: record.date)

        durationLabel.text = record.formattedDuration
        qualityLabel.text = "Quality: \(record.qualityScore)%"

        sleepBarsView.subviews.forEach { $0.removeFromSuperview() }

        let colors: [UIColor] = [.sleepDeepColor, .sleepLightColor, .sleepRemColor]
        let values = [record.deepSleepMinutes, record.lightSleepMinutes, record.remSleepMinutes]
        let total = values.reduce(0, +)
        var x: CGFloat = 0

        for (index, value) in values.enumerated() {
            let width = CGFloat(value) / CGFloat(max(total, 1)) * 60
            let bar = UIView()
            bar.backgroundColor = colors[index]
            bar.layer.cornerRadius = 2
            sleepBarsView.addSubview(bar)
            bar.frame = CGRect(x: x, y: 0, width: width, height: 40)
            x += width + 2
        }
    }
}

final class SleepDetailViewController: UIViewController {
    var record: SleepRecord?

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sleep Details"
        view.backgroundColor = UIColor.backgroundColor
        setupUI()
        displayRecord()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    }

    private func displayRecord() {
        guard let record = record else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"

        let titleLabel = UILabel()
        titleLabel.text = formatter.string(from: record.date)
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = UIColor.textPrimary

        let durationCard = createStatCard(title: "Total Sleep", value: record.formattedDuration, icon: "moon.fill")
        let qualityCard = createStatCard(title: "Quality Score", value: "\(record.qualityScore)%", icon: "star.fill")
        let deepCard = createStatCard(title: "Deep Sleep", value: "\(record.deepSleepMinutes) min", icon: "moon.zzz.fill")
        let lightCard = createStatCard(title: "Light Sleep", value: "\(record.lightSleepMinutes) min", icon: "cloud.fill")
        let remCard = createStatCard(title: "REM Sleep", value: "\(record.remSleepMinutes) min", icon: "eye.fill")
        let awakeCard = createStatCard(title: "Awake Time", value: "\(record.awakeMinutes) min", icon: "exclamationmark.triangle.fill")

        contentView.addSubview(titleLabel)
        contentView.addSubview(durationCard)
        contentView.addSubview(qualityCard)
        contentView.addSubview(deepCard)
        contentView.addSubview(lightCard)
        contentView.addSubview(remCard)
        contentView.addSubview(awakeCard)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        let cardWidth = (UIScreen.main.bounds.width - 60) / 2

        durationCard.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(cardWidth)
            make.height.equalTo(100)
        }

        qualityCard.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(cardWidth)
            make.height.equalTo(100)
        }

        deepCard.snp.makeConstraints { make in
            make.top.equalTo(durationCard.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(cardWidth)
            make.height.equalTo(100)
        }

        lightCard.snp.makeConstraints { make in
            make.top.equalTo(durationCard.snp.bottom).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(cardWidth)
            make.height.equalTo(100)
        }

        remCard.snp.makeConstraints { make in
            make.top.equalTo(deepCard.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(cardWidth)
            make.height.equalTo(100)
        }

        awakeCard.snp.makeConstraints { make in
            make.top.equalTo(deepCard.snp.bottom).offset(12)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(cardWidth)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func createStatCard(title: String, value: String, icon: String) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.cardBackground
        card.layer.cornerRadius = 12

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = UIColor.primaryColor

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.textSecondary

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = UIColor.textPrimary

        card.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)

        iconView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
        }

        return card
    }
}