import UIKit

class HomeViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var allFeedItems: [FeedItem] = []
    private let refreshControl = UIRefreshControl()

    /// Feed items filtered to exclude blocked users and reported items
    private var feedItems: [FeedItem] {
        let blocked = BlocklistManager.shared.blockedUsers
        let reported = BlocklistManager.shared.reportedItemIds
        return allFeedItems.filter { !blocked.contains($0.authorName) && !reported.contains($0.id) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Discover"

        setupCollectionView()
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
        if let layout = collectionView.collectionViewLayout as? WaterfallLayout {
            layout.invalidateLayoutCache()
        }
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupCollectionView() {
        let layout = WaterfallLayout()
        layout.delegate = self

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HomeFeedCell.self, forCellWithReuseIdentifier: HomeFeedCell.reuseIdentifier)

        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .label
        refreshControl.attributedTitle = NSAttributedString(string: "Loading latest analog shots...", attributes: [.foregroundColor: UIColor.label])
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)
    }

    @objc private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.allFeedItems = FeedItem.mockData(count: 30)
            if let layout = self?.collectionView.collectionViewLayout as? WaterfallLayout {
                layout.invalidateLayoutCache()
            }
            self?.collectionView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }

    private func loadMockData() {
        allFeedItems = FeedItem.mockData(count: 20)
        collectionView.reloadData()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeFeedCell.reuseIdentifier, for: indexPath) as! HomeFeedCell
        cell.configure(with: feedItems[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = PhotoDetailViewController()
        detailVC.feedItem = feedItems[indexPath.row]
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }

    // Context menu for Report / Block (long press)
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let item = feedItems[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let reportAction = UIAction(
                title: "Report Content",
                image: UIImage(systemName: "flag"),
                attributes: .destructive
            ) { _ in
                self?.showReportAlert(for: item)
            }
            let blockAction = UIAction(
                title: "Block \(item.authorName)",
                image: UIImage(systemName: "person.slash"),
                attributes: .destructive
            ) { _ in
                self?.showBlockAlert(for: item)
            }
            return UIMenu(title: "", children: [reportAction, blockAction])
        }
    }

    // Infinite scrolling basic setup
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (collectionView.contentSize.height - 100 - scrollView.frame.size.height) {
            // Load more data...
        }
    }

    // MARK: - Report / Block Helpers

    private func showReportAlert(for item: FeedItem) {
        let alert = UIAlertController(title: "Report Content", message: "Why are you reporting this post?", preferredStyle: .actionSheet)
        let reasons = ["Objectionable content", "Spam or misleading", "Harassment", "Hate speech", "Other"]
        for reason in reasons {
            alert.addAction(UIAlertAction(title: reason, style: .destructive) { [weak self] _ in
                BlocklistManager.shared.reportItem(itemId: item.id, username: item.authorName)
                self?.collectionView.reloadData()
                self?.showToast(message: "Content reported. Thank you for your feedback.")
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }

    private func showBlockAlert(for item: FeedItem) {
        let alert = UIAlertController(
            title: "Block \(item.authorName)?",
            message: "You will no longer see posts from this user. This will also notify us to review their content.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            BlocklistManager.shared.blockUser(item.authorName)
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
        UIView.animate(withDuration: 0.3, delay: 2.5, options: .curveEaseOut) {
            toast.alpha = 0
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }
}

extension HomeViewController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        let item = feedItems[indexPath.row]
        let itemWidth = (collectionView.bounds.width - 24) / 2
        return itemWidth * item.aspectRatio
    }
}

