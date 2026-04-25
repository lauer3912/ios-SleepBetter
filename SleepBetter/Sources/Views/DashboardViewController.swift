import UIKit
import SnapKit
import Combine

final class DashboardViewController: UIViewController {

    private let viewModel = DashboardViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private lazy var contentView = UIView()

    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor.textPrimary
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.textSecondary
        return label
    }()

    private lazy var sleepCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cardBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private lazy var sleepTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Last Night's Sleep"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.textSecondary
        return label
    }()

    private lazy var sleepHoursLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = UIColor.textPrimary
        label.text = "7h 45m"
        return label
    }()

    private lazy var qualityBadge: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.successColor.withAlphaComponent(0.2)
        view.layer.cornerRadius = 12
        return view
    }()

    private lazy var qualityLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.successColor
        label.text = "Good"
        return label
    }()

    private lazy var sleepGraphView: SleepGraphView = {
        let view = SleepGraphView()
        return view
    }()

    private lazy var insightCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var insightTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Insights"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.textPrimary
        return label
    }()

    private lazy var insightStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()

    private lazy var quickActionsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fillEqually
        return sv
    }()

    private lazy var bedtimeButton: QuickActionButton = {
        let button = QuickActionButton()
        button.configure(icon: "bed.double.fill", title: "Sleep Now", color: UIColor.primaryColor)
        button.addTarget(self, action: #selector(sleepNowTapped), for: .touchUpInside)
        return button
    }()

    private lazy var alarmButton: QuickActionButton = {
        let button = QuickActionButton()
        button.configure(icon: "alarm.fill", title: "Set Alarm", color: UIColor.accentColor)
        button.addTarget(self, action: #selector(setAlarmTapped), for: .touchUpInside)
        return button
    }()

    private lazy var audioButton: QuickActionButton = {
        let button = QuickActionButton()
        button.configure(icon: "waveform", title: "Play Sounds", color: UIColor.sleepDeepColor)
        button.addTarget(self, action: #selector(playSoundsTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refreshData()
        updateUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(greetingLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(sleepCard)
        sleepCard.addSubview(sleepTitleLabel)
        sleepCard.addSubview(sleepHoursLabel)
        sleepCard.addSubview(qualityBadge)
        qualityBadge.addSubview(qualityLabel)
        sleepCard.addSubview(sleepGraphView)
        contentView.addSubview(quickActionsStack)
        quickActionsStack.addArrangedSubview(bedtimeButton)
        quickActionsStack.addArrangedSubview(alarmButton)
        quickActionsStack.addArrangedSubview(audioButton)
        contentView.addSubview(insightCard)
        insightCard.addSubview(insightTitleLabel)
        insightCard.addSubview(insightStackView)

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        greetingLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(greetingLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(20)
        }

        sleepCard.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        sleepTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        sleepHoursLabel.snp.makeConstraints { make in
            make.top.equalTo(sleepTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }

        qualityBadge.snp.makeConstraints { make in
            make.centerY.equalTo(sleepHoursLabel)
            make.leading.equalTo(sleepHoursLabel.snp.trailing).offset(12)
        }

        qualityLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12))
        }

        sleepGraphView.snp.makeConstraints { make in
            make.top.equalTo(sleepHoursLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-16)
        }

        quickActionsStack.snp.makeConstraints { make in
            make.top.equalTo(sleepCard.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }

        insightCard.snp.makeConstraints { make in
            make.top.equalTo(quickActionsStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        insightTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }

        insightStackView.snp.makeConstraints { make in
            make.top.equalTo(insightTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    private func setupBindings() {
        viewModel.$todaySleep
            .receive(on: DispatchQueue.main)
            .sink { [weak self] record in
                self?.updateSleepCard(record)
            }
            .store(in: &cancellables)
    }

    private func updateUI() {
        greetingLabel.text = viewModel.greeting

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        dateLabel.text = formatter.string(from: Date())

        updateInsights()
    }

    private func updateSleepCard(_ record: SleepRecord?) {
        if let record = record {
            sleepHoursLabel.text = record.formattedDuration
            qualityLabel.text = viewModel.sleepQualityText
            sleepGraphView.updateGraph(with: record)
        } else {
            sleepHoursLabel.text = "--"
            qualityLabel.text = "No data"
        }
    }

    private func updateInsights() {
        insightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for insight in viewModel.insights {
            let insightView = InsightView()
            insightView.configure(with: insight)
            insightStackView.addArrangedSubview(insightView)
        }
    }

    @objc private func sleepNowTapped() {
        let alert = UIAlertController(title: "Start Sleep Mode", message: "Tap the moon icon when you go to bed and the sun when you wake up.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Go to Sleep", style: .default) { [weak self] _ in
            self?.showBedtimeStarted()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func setAlarmTapped() {
        let alarmVC = SetAlarmViewController()
        navigationController?.pushViewController(alarmVC, animated: true)
    }

    @objc private func playSoundsTapped() {
        tabBarController?.selectedIndex = 2
    }

    private func showBedtimeStarted() {
        let alert = UIAlertController(title: "Sweet Dreams", message: "Sleep mode started. Wake up refreshed!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

final class QuickActionButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = UIColor.cardBackground
        layer.cornerRadius = 12
        titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        setTitleColor(UIColor.textSecondary, for: .normal)
    }

    func configure(icon: String, title: String, color: UIColor) {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: icon)
        config.imagePadding = 8
        config.title = title
        config.imagePlacement = .top
        config.baseForegroundColor = color
        configuration = config
    }
}

final class SleepGraphView: UIView {
    private var bars: [UIView] = []
    private var data: [Double] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateGraph(with record: SleepRecord) {
        data = [
            Double(record.deepSleepMinutes) / 60.0,
            Double(record.lightSleepMinutes) / 60.0,
            Double(record.remSleepMinutes) / 60.0,
            Double(record.awakeMinutes) / 60.0
        ]
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        let barWidth: CGFloat = rect.width / CGFloat(data.count + 1) - 8
        var x: CGFloat = 16

        let colors: [UIColor] = [.sleepDeepColor, .sleepLightColor, .sleepRemColor, .textSecondary]

        for (index, value) in data.enumerated() {
            let maxHeight: CGFloat = rect.height - 20
            let barHeight = CGFloat(value) / 10.0 * maxHeight

            context?.setFillColor(colors[index].cgColor)
            let barRect = CGRect(x: x, y: rect.height - barHeight - 10, width: barWidth, height: barHeight)
            context?.fill(barRect)

            x += barWidth + 8
        }

        let legendItems = ["Deep", "Light", "REM", "Awake"]
        x = 16
        for (index, _) in legendItems.enumerated() {
            context?.setFillColor(colors[index].cgColor)
            let dotRect = CGRect(x: x, y: rect.height - 8, width: 8, height: 8)
            context?.fillEllipse(in: dotRect)
            x += barWidth + 8
        }
    }
}

final class InsightView: UIView {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descLabel)

        iconView.tintColor = UIColor.primaryColor
        iconView.contentMode = .scaleAspectFit

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor.textPrimary

        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = UIColor.textSecondary
        descLabel.numberOfLines = 2

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.bottom.equalToSuperview()
        }
    }

    func configure(with insight: SleepInsight) {
        iconView.image = UIImage(systemName: insight.icon)
        titleLabel.text = insight.title
        descLabel.text = insight.description
    }
}