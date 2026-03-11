import UIKit
import StoreKit

class StoreViewController: UIViewController {
    
    private let collectionView: UICollectionView
    private let balanceLabel = UILabel()
    private var products: [SKProduct] = []
    
    // Fallback UI data before App Store Connect fetch
    private let fallbackData: [(title: String, price: String)] = [
        ("32 coins", "$0.99"), ("60 coins", "$1.99"), ("96 coins", "$2.99"),
        ("155 coins", "$4.99"), ("189 coins", "$5.99"), ("359 coins", "$9.99"),
        ("729 coins", "$19.99"), ("1869 coins", "$49.99"), ("3799 coins", "$99.99")
    ]
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 24, right: 16)
        
        // 2 columns
        let width = (UIScreen.main.bounds.width - 32 - 16) / 2
        layout.itemSize = CGSize(width: width, height: 120)
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Store"
        view.backgroundColor = .systemGroupedBackground
        
        setupUI()
        updateBalance()
        
        // Listen for balance changes
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance), name: CoinManager.balanceDidChangeNotification, object: nil)
        
        // Fetch real IAP products
        IAPManager.shared.onProductsFetched = { [weak self] fetchedProducts in
            self?.products = fetchedProducts
            self?.collectionView.reloadData()
        }
        IAPManager.shared.fetchProducts()
        
        // Handle Purchase callbacks
        IAPManager.shared.onPurchaseResult = { [weak self] success, message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: success ? "Success" : "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    private func setupUI() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = .systemBackground
        headerView.layer.cornerRadius = 16
        view.addSubview(headerView)
        
        let coinIcon = UIImageView(image: UIImage(systemName: "dollarsign.circle.fill"))
        coinIcon.tintColor = .systemYellow
        coinIcon.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(coinIcon)
        
        balanceLabel.font = .systemFont(ofSize: 32, weight: .bold)
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(balanceLabel)
        
        let balanceDesc = UILabel()
        balanceDesc.text = "Current Balance"
        balanceDesc.font = .systemFont(ofSize: 14, weight: .medium)
        balanceDesc.textColor = .secondaryLabel
        balanceDesc.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(balanceDesc)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(StoreItemCell.self, forCellWithReuseIdentifier: "StoreItemCell")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            coinIcon.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            coinIcon.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            coinIcon.widthAnchor.constraint(equalToConstant: 48),
            coinIcon.heightAnchor.constraint(equalToConstant: 48),
            
            balanceLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            balanceLabel.leadingAnchor.constraint(equalTo: coinIcon.trailingAnchor, constant: 16),
            
            balanceDesc.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 4),
            balanceDesc.leadingAnchor.constraint(equalTo: balanceLabel.leadingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func updateBalance() {
        DispatchQueue.main.async {
            self.balanceLabel.text = "\(CoinManager.shared.currentBalance)"
        }
    }
}

extension StoreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.isEmpty ? fallbackData.count : products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreItemCell", for: indexPath) as! StoreItemCell
        
        if products.isEmpty {
            // Show mock layout while loading
            let data = fallbackData[indexPath.row]
            cell.configureFallback(title: data.title, price: data.price)
        } else {
            // Show real StoreKit layout
            let product = products[indexPath.row]
            cell.configure(with: product)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if products.isEmpty {
            let alert = UIAlertController(title: "Loading", message: "Still connecting to App Store...", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let product = products[indexPath.row]
        let alert = UIAlertController(title: "Purchase Coins", message: "Buy \(product.localizedTitle) for \(product.price)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Buy", style: .default, handler: { _ in
            IAPManager.shared.purchase(product: product)
        }))
        present(alert, animated: true)
    }
}

class StoreItemCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let buyButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.05
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        priceLabel.font = .systemFont(ofSize: 16, weight: .medium)
        priceLabel.textColor = .systemBlue
        priceLabel.textAlignment = .center
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        buyButton.setTitle("Buy", for: .normal)
        buyButton.backgroundColor = .systemBlue
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.layer.cornerRadius = 8
        buyButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        buyButton.isUserInteractionEnabled = false // Cell selection triggers action
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buyButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            buyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            buyButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buyButton.widthAnchor.constraint(equalToConstant: 80),
            buyButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with product: SKProduct) {
        titleLabel.text = product.localizedTitle.isEmpty ? "Coins" : product.localizedTitle
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        priceLabel.text = formatter.string(from: product.price)
    }
    
    func configureFallback(title: String, price: String) {
        titleLabel.text = title
        priceLabel.text = price
    }
}
