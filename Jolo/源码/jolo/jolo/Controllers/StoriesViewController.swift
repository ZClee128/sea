import UIKit

class StoriesViewController: UIViewController {

    private var tableView: UITableView!
    private var allStories: [FeedItem] = []

    /// Filtered stories excluding blocked users and reported items
    private var visibleStories: [FeedItem] {
        let blocked = BlocklistManager.shared.blockedUsers
        let reported = BlocklistManager.shared.reportedItemIds
        return allStories.filter { !blocked.contains($0.authorName) && !reported.contains($0.id) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Journal"

        setupTableView()
        loadMockData()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(blocklistChanged),
            name: .blockedUsersChanged,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func blocklistChanged() {
        tableView.reloadData()
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StoryTableViewCell.self, forCellReuseIdentifier: StoryTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
    }

    private func loadMockData() {
        allStories = FeedItem.mockData(count: 10)
        tableView.reloadData()
    }
}

extension StoriesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleStories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoryTableViewCell.reuseIdentifier, for: indexPath) as! StoryTableViewCell
        cell.configure(with: visibleStories[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryTableViewCellDelegate

extension StoriesViewController: StoryTableViewCellDelegate {

    func storyCell(_ cell: StoryTableViewCell, didRequestReportForItem item: FeedItem) {
        let alert = UIAlertController(
            title: "Report Content",
            message: "Why are you reporting this post?",
            preferredStyle: .actionSheet
        )
        let reasons = ["Objectionable content", "Spam or misleading", "Harassment", "Hate speech", "Other"]
        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason, style: .destructive) { [weak self] _ in
                BlocklistManager.shared.reportItem(itemId: item.id, username: item.authorName)
                self?.tableView.reloadData()
                self?.showToast(message: "Content reported. Thank you for your feedback.")
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        present(alert, animated: true)
    }

    func storyCell(_ cell: StoryTableViewCell, didRequestBlockUser item: FeedItem) {
        let alert = UIAlertController(
            title: "Block \(item.authorName)?",
            message: "You will no longer see posts from this user. This will also notify us to review their content.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            BlocklistManager.shared.blockUser(item.authorName)
            // visibleStories will automatically exclude blocked user; reload
            self?.tableView.reloadData()
            self?.showToast(message: "\(item.authorName) has been blocked.")
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showToast(message: String) {
        let toast = UILabel()
        toast.text = message
        toast.textColor = .white
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toast.font = .systemFont(ofSize: 13, weight: .medium)
        toast.textAlignment = .center
        toast.numberOfLines = 0
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toast)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            toast.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        toast.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        UIView.animate(withDuration: 0.3, delay: 2.5, options: .curveEaseOut) {
            toast.alpha = 0
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
}
