import UIKit
import SnapKit

final class AudioLibraryViewController: UIViewController {

    private var audioCategories: [SleepAudio.AudioCategory] = [.whiteNoise, .nature, .ambient, .meditation]
    private var selectedCategory: SleepAudio.AudioCategory = .whiteNoise
    private var currentlyPlaying: String?

    private lazy var categorySegment: UISegmentedControl = {
        let items = audioCategories.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(categoryChanged), for: .valueChanged)
        return control
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(AudioCell.self, forCellReuseIdentifier: "AudioCell")
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    private lazy var nowPlayingBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cardBackground
        view.layer.cornerRadius = 16
        view.isHidden = true
        return view
    }()

    private lazy var nowPlayingTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.textPrimary
        return label
    }()

    private lazy var nowPlayingCategory: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = UIColor.textSecondary
        return label
    }()

    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = UIColor.primaryColor
        button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        return button
    }()

    private lazy var stopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        button.tintColor = UIColor.textSecondary
        button.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        return button
    }()

    private var availableAudios: [SleepAudio] {
        DashboardViewModel().getAvailableAudios().filter { $0.category == selectedCategory }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Sounds"
        view.backgroundColor = UIColor.backgroundColor

        view.addSubview(categorySegment)
        view.addSubview(tableView)
        view.addSubview(nowPlayingBar)
        nowPlayingBar.addSubview(nowPlayingTitle)
        nowPlayingBar.addSubview(nowPlayingCategory)
        nowPlayingBar.addSubview(playPauseButton)
        nowPlayingBar.addSubview(stopButton)

        categorySegment.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(categorySegment.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(nowPlayingBar.snp.top).offset(-16)
        }

        nowPlayingBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(60)
        }

        nowPlayingTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(16)
        }

        nowPlayingCategory.snp.makeConstraints { make in
            make.top.equalTo(nowPlayingTitle.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(16)
        }

        stopButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(playPauseButton.snp.leading).offset(-16)
            make.width.height.equalTo(32)
        }

        playPauseButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(32)
        }
    }

    @objc private func categoryChanged() {
        selectedCategory = audioCategories[categorySegment.selectedSegmentIndex]
        tableView.reloadData()
    }

    @objc private func playPauseTapped() {
        if currentlyPlaying != nil {
            if playPauseButton.currentImage == UIImage(systemName: "pause.fill") {
                playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            } else {
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
        }
    }

    @objc private func stopTapped() {
        currentlyPlaying = nil
        nowPlayingBar.isHidden = true
    }

    private func playAudio(_ audio: SleepAudio) {
        currentlyPlaying = audio.name
        nowPlayingBar.isHidden = false
        nowPlayingTitle.text = audio.name
        nowPlayingCategory.text = audio.category.rawValue
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        tableView.reloadData()
    }
}

extension AudioLibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableAudios.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as! AudioCell
        let audio = availableAudios[indexPath.row]
        cell.configure(with: audio, isPlaying: currentlyPlaying == audio.name)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let audio = availableAudios[indexPath.row]
        playAudio(audio)
    }
}

final class AudioCell: UITableViewCell {
    private let containerView = UIView()
    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let durationLabel = UILabel()
    private let playButton = UIButton(type: .system)

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

        containerView.addSubview(iconView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(durationLabel)
        containerView.addSubview(playButton)

        iconView.tintColor = UIColor.primaryColor
        iconView.contentMode = .scaleAspectFit
        iconView.image = UIImage(systemName: "waveform")

        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = UIColor.textPrimary

        durationLabel.font = .systemFont(ofSize: 14)
        durationLabel.textColor = UIColor.textSecondary

        playButton.tintColor = UIColor.primaryColor

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        }

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
        }

        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
        }

        playButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
    }

    func configure(with audio: SleepAudio, isPlaying: Bool) {
        nameLabel.text = audio.name
        let minutes = audio.duration / 60
        durationLabel.text = "\(minutes) min"
        playButton.setImage(UIImage(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill"), for: .normal)
    }
}