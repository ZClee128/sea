//
//  DiscoveryViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class DiscoveryViewController: UIViewController {
    
    // MARK: - Properties
    private var allPosts: [Post] = []
    
    // Data structure for shelves: [(Title, [Post])]
    private var shelves: [(title: String, posts: [Post])] = []
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.showsVerticalScrollIndicator = false
        
        // Register Cell
        cv.register(ShelfCell.self, forCellWithReuseIdentifier: ShelfCell.identifier)
        
        // Register Header
        cv.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Discover"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupUI()
        loadData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePostsUpdated),
            name: NSNotification.Name("PostsUpdated"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // Shelf Layout (Same for all sections)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            
            // Group Width: relative to screen width (e.g. 0.4 for small cards, 0.8 for large)
            // Let's vary the width per section to make it interesting!
            let widthFraction: CGFloat = (sectionIndex == 0) ? 0.85 : 0.45
            let height: CGFloat = (sectionIndex == 0) ? 220 : 200
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(widthFraction), heightDimension: .absolute(height))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 30, trailing: 16)
            
            // Header
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        return layout
    }
    
    // MARK: - Data Management
    
    @objc private func handleRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc private func handlePostsUpdated() {
        loadData()
    }
    
    private func loadData() {
        allPosts = MockDataService.shared.mockPosts
        
        // Build Shelves
        shelves.removeAll()
        
        // 1. Featured / Trending (Top liked)
        let trending = allPosts.sorted(by: { $0.likeCount > $1.likeCount }).prefix(5)
        shelves.append(("Trending Now 🔥", Array(trending)))
        
        // 2. Categories
        let categories = ["Nature", "Urban", "Travel", "Lifestyle"]
        
        for cat in categories {
            // Simple filter simulation
            let filtered = allPosts.filter { post in
                let text = (post.caption + " " + (post.location ?? "")).lowercased()
                return text.contains(cat.lowercased())
            }
            
            // Fallback content if filter is empty (for demo)
            let content = filtered.isEmpty ? Array(allPosts.prefix(4)) : filtered
            shelves.append((cat, content))
        }
        
        // 3. New Arrivals
        let newPosts = allPosts.sorted(by: { $0.createdAt > $1.createdAt }).prefix(6)
        shelves.append(("Fresh Finds ✨", Array(newPosts)))
        
        collectionView.reloadData()
    }
}

// MARK: - Delegate & DataSource

extension DiscoveryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return shelves.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shelves[section].posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShelfCell.identifier, for: indexPath) as? ShelfCell else {
            return UICollectionViewCell()
        }
        
        let post = shelves[indexPath.section].posts[indexPath.item]
        // Vary style based on section?
        // Section 0 is "Trending" (Big cards)
        // Others are "Standard" (Small cards)
        let isFeatured = (indexPath.section == 0)
        cell.configure(with: post, isFeatured: isFeatured)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath) as! SectionHeaderView
        header.titleLabel.text = shelves[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = shelves[indexPath.section].posts[indexPath.item]
        let detailVC = PostDetailViewController(post: post)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Cells & Views

class SectionHeaderView: UICollectionReusableView {
    static let identifier = "SectionHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = .secondaryLabel
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
//        addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
//            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            arrowImageView.widthAnchor.constraint(equalToConstant: 12),
//            arrowImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

class ShelfCell: UICollectionViewCell {
    static let identifier = "ShelfCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let overlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
        contentView.addSubview(titleLabel)
        
        // Shadow for cell
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.masksToBounds = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with post: Post, isFeatured: Bool) {
        let urlStr = (post.type == .video) ? (post.thumbnailURL ?? post.mediaURL) : post.mediaURL
        imageView.loadImage(from: URL(string: urlStr))
        
        if isFeatured {
            // Bigger text for featured section
            titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
            titleLabel.numberOfLines = 2
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        } else {
            titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
            titleLabel.numberOfLines = 1
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        
        titleLabel.text = post.caption
    }
}
