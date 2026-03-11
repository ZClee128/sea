import UIKit
import AVKit

class MasterclassViewController: UIViewController {
    
    private let tableView = UITableView()
    private var lessons: [VideoLesson] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Masterclass"
        view.backgroundColor = .systemBackground
        
        loadData()
        setupTableView()
    }
    
    private func loadData() {
        lessons = InspirationDataService.shared.fetchVideos()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MasterclassCell.self, forCellReuseIdentifier: "MasterclassCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerVC = BackgroundPlayerViewController()
        playerVC.player = player
        
        // Ensure background audio works even if silent switch is on (since we set category in AppDelegate)
        playerVC.allowsPictureInPicturePlayback = true
        
        present(playerVC, animated: true) {
            player.play()
        }
        
        // Add looping observer
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
        }
    }
}

class BackgroundPlayerViewController: AVPlayerViewController {
    
    // Hold a strong reference so the player isn't deallocated when detached from the view
    private var heldPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heldPlayer = self.player
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Ensure player is paused if the view is actually dismissed
        if isBeingDismissed {
            heldPlayer?.pause()
        }
    }
    
    @objc private func appDidEnterBackground() {
        // Officially detach player from view layer to prevent automatic pausing by AVKit
        self.player = nil
        // It might pause momentarily during detachment, so let's force it to play again immediately
        heldPlayer?.play()
    }
    
    @objc private func appWillEnterForeground() {
        // Restore the player to the view so the user can see the video again
        self.player = heldPlayer
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MasterclassViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MasterclassCell", for: indexPath) as! MasterclassCell
        cell.configure(with: lessons[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let lesson = lessons[indexPath.row]
        let url: URL
        if let localUrl = Bundle.main.url(forResource: lesson.videoUrlString, withExtension: "mp4") {
            url = localUrl
        } else if let remoteUrl = URL(string: lesson.videoUrlString) {
            url = remoteUrl
        } else {
            return
        }
        playVideo(url: url)
    }
}

class MasterclassCell: UITableViewCell {
    
    private let thumbnailImageView = UIImageView()
    private let playIconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let durationLabel = UILabel()
    private let cardView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(thumbnailImageView)
        
        // Dark gradient overlay for text readability
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(overlay)
        
        playIconImageView.image = UIImage(systemName: "play.circle.fill")
        playIconImageView.tintColor = .white
        playIconImageView.contentMode = .scaleAspectFit
        playIconImageView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(playIconImageView)
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = .lightText
        subtitleLabel.numberOfLines = 2
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(subtitleLabel)
        
        let durationWrapper = UIView()
        durationWrapper.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        durationWrapper.layer.cornerRadius = 6
        durationWrapper.translatesAutoresizingMaskIntoConstraints = false
        
        durationLabel.font = .systemFont(ofSize: 12, weight: .medium)
        durationLabel.textColor = .white
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        durationWrapper.addSubview(durationLabel)
        cardView.addSubview(durationWrapper)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            cardView.heightAnchor.constraint(equalToConstant: 240),
            
            thumbnailImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            
            overlay.topAnchor.constraint(equalTo: cardView.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            
            playIconImageView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            playIconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            playIconImageView.widthAnchor.constraint(equalToConstant: 64),
            playIconImageView.heightAnchor.constraint(equalToConstant: 64),
            
            subtitleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -4),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            durationWrapper.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),
            durationWrapper.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            durationLabel.topAnchor.constraint(equalTo: durationWrapper.topAnchor, constant: 4),
            durationLabel.bottomAnchor.constraint(equalTo: durationWrapper.bottomAnchor, constant: -4),
            durationLabel.leadingAnchor.constraint(equalTo: durationWrapper.leadingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: durationWrapper.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with lesson: VideoLesson) {
        titleLabel.text = lesson.title
        subtitleLabel.text = lesson.subtitle
        durationLabel.text = lesson.duration
        
        if let thumb = UIImage(named: lesson.thumbnailName) {
            thumbnailImageView.image = thumb
        } else if let path = Bundle.main.path(forResource: lesson.thumbnailName, ofType: nil), let image = UIImage(contentsOfFile: path) {
            thumbnailImageView.image = image
        } else {
            thumbnailImageView.backgroundColor = .darkGray
        }
    }
}
