import UIKit

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var feedItems: [FeedItem] = []
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Discover"
        
        setupCollectionView()
        loadMockData()
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
            // Shuffle and replace for effect
            self?.feedItems = FeedItem.mockData(count: 30)
            if let layout = self?.collectionView.collectionViewLayout as? WaterfallLayout {
                layout.invalidateLayoutCache()
            }
            self?.collectionView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    private func loadMockData() {
        feedItems = FeedItem.mockData(count: 20)
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
        // Handle navigation to image detail
        let detailVC = PhotoDetailViewController()
        detailVC.feedItem = feedItems[indexPath.row]
        detailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // Infinite scrolling basic setup
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (collectionView.contentSize.height - 100 - scrollView.frame.size.height) {
            // Load more data... we'll add a debounce here
        }
    }
}

extension HomeViewController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        let item = feedItems[indexPath.row]
        let itemWidth = (collectionView.bounds.width - 24) / 2 // Approximate cell width based on 2 columns and padding
        return itemWidth * item.aspectRatio
    }
}
