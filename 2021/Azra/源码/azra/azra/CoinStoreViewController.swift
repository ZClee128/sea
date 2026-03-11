import UIKit
import StoreKit

class CoinStoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let headerView = UIView()
    private let coinBalanceLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var skProducts: [SKProduct] = []    // From App Store (live price)
    private var isLoading = true
    
    // Observer tokens
    private var successObserver: NSObjectProtocol?
    private var failureObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Buy Coins"
        view.backgroundColor = .systemGroupedBackground
        setupHeaderView()
        setupTableView()
        setupObservers()
        fetchProducts()
    }
    
    deinit {
        successObserver.map { NotificationCenter.default.removeObserver($0) }
        failureObserver.map { NotificationCenter.default.removeObserver($0) }
    }
    
    // MARK: - Setup
    
    private func setupHeaderView() {
        // Use a fixed frame — tableHeaderView doesn't support auto layout
        let headerHeight: CGFloat = 130
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerHeight)
        headerView.backgroundColor = .systemBackground
        
        // Coin icon
        let coinIcon = UIImageView(image: UIImage(systemName: "bitcoinsign.circle.fill"))
        coinIcon.tintColor = .systemYellow
        coinIcon.contentMode = .scaleAspectFit
        coinIcon.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        // Balance label
        coinBalanceLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        coinBalanceLabel.textColor = .label
        coinBalanceLabel.textAlignment = .center
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your Coin Balance"
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        
        // Stack everything vertically and center it
        let stack = UIStackView(arrangedSubviews: [coinIcon, coinBalanceLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            coinIcon.widthAnchor.constraint(equalToConstant: 40),
            coinIcon.heightAnchor.constraint(equalToConstant: 40),
            stack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
        ])
        
        // Separator at the bottom
        let separator = UIView(frame: CGRect(x: 0, y: headerHeight - 0.5, width: UIScreen.main.bounds.width, height: 0.5))
        separator.backgroundColor = .separator
        headerView.addSubview(separator)
        
        updateBalance()
        
        NotificationCenter.default.addObserver(forName: CoinManager.balanceChangedNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateBalance()
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CoinProductCell.self, forCellReuseIdentifier: "CoinProductCell")
        tableView.tableHeaderView = headerView   // Frame already set, safe to assign
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupObservers() {
        successObserver = NotificationCenter.default.addObserver(forName: .iapPurchaseSucceeded, object: nil, queue: .main) { [weak self] notification in
            self?.stopLoading()
            let productID = notification.object as? String ?? ""
            let product = allCoinProducts.first { $0.productID == productID }
            let coinsAdded = product?.totalCoins ?? 0
            let alert = UIAlertController(title: "Purchase Successful! 🎉", message: "You received \(coinsAdded) coins!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Great!", style: .default))
            self?.present(alert, animated: true)
        }
        
        failureObserver = NotificationCenter.default.addObserver(forName: .iapPurchaseFailed, object: nil, queue: .main) { [weak self] notification in
            self?.stopLoading()
            let message = notification.object as? String ?? "Purchase could not be completed."
            
            // Do not show an alert if the user explicitly cancelled the payment
            if message != "cancelled" {
                let alert = UIAlertController(title: "Purchase Failed", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Products
    
    private func fetchProducts() {
        StoreManager.shared.fetchProducts { [weak self] products in
            guard let self = self else { return }
            self.skProducts = products.sorted { p1, p2 in
                let idx1 = allCoinProducts.firstIndex { $0.productID == p1.productIdentifier } ?? 99
                let idx2 = allCoinProducts.firstIndex { $0.productID == p2.productIdentifier } ?? 99
                return idx1 < idx2
            }
            self.isLoading = false
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    private func updateBalance() {
        coinBalanceLabel.text = "\(CoinManager.shared.balance)"
    }
    
    private func stopLoading() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // While loading, show all static products; after load, show matched to skProducts
        if isLoading { return 0 }
        return skProducts.isEmpty ? allCoinProducts.count : skProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinProductCell", for: indexPath) as! CoinProductCell
        
        if !skProducts.isEmpty {
            let skProduct = skProducts[indexPath.row]
            let localProduct = allCoinProducts.first { $0.productID == skProduct.productIdentifier }
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = skProduct.priceLocale
            let priceString = formatter.string(from: skProduct.price) ?? "—"
            cell.configure(name: skProduct.localizedTitle.isEmpty ? (localProduct?.displayName ?? "") : localProduct?.displayName ?? skProduct.localizedTitle,
                           price: priceString,
                           bonus: (localProduct?.bonusCoins ?? 0) > 0)
        } else {
            // Fallback: show static data
            let product = allCoinProducts[indexPath.row]
            cell.configure(name: product.displayName, price: product.price, bonus: product.bonusCoins > 0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Choose a Pack"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard !skProducts.isEmpty else {
            // Products haven't loaded from App Store yet
            let alert = UIAlertController(title: "Loading…", message: "Product information is still loading. Please try again in a moment.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let product = skProducts[indexPath.row]
        activityIndicator.startAnimating()
        StoreManager.shared.purchase(product: product)
    }
}

// MARK: - CoinProductCell

class CoinProductCell: UITableViewCell {
    
    private let coinLabel = UILabel()
    private let priceLabel = UILabel()
    private let bonusBadge = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        let coinIcon = UIImageView(image: UIImage(systemName: "bitcoinsign.circle.fill"))
        coinIcon.tintColor = .systemYellow
        coinIcon.contentMode = .scaleAspectFit
        coinIcon.setContentHuggingPriority(.required, for: .horizontal)
        coinIcon.translatesAutoresizingMaskIntoConstraints = false
        
        coinLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        coinLabel.translatesAutoresizingMaskIntoConstraints = false
        // Allow the name to truncate before the price does
        coinLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        priceLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        priceLabel.textColor = .systemIndigo
        priceLabel.textAlignment = .right
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        // Price must never be truncated
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        bonusBadge.text = "BONUS"
        bonusBadge.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        bonusBadge.textColor = .white
        bonusBadge.backgroundColor = .systemOrange
        bonusBadge.textAlignment = .center
        bonusBadge.layer.cornerRadius = 4
        bonusBadge.clipsToBounds = true
        bonusBadge.isHidden = true
        bonusBadge.setContentHuggingPriority(.required, for: .horizontal)
        bonusBadge.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [coinIcon, coinLabel, bonusBadge, priceLabel])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            coinIcon.widthAnchor.constraint(equalToConstant: 28),
            coinIcon.heightAnchor.constraint(equalToConstant: 28),
            bonusBadge.widthAnchor.constraint(equalToConstant: 48),
            bonusBadge.heightAnchor.constraint(equalToConstant: 18),
            
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(name: String, price: String, bonus: Bool) {
        coinLabel.text = name
        priceLabel.text = price
        bonusBadge.isHidden = !bonus
        accessoryType = .disclosureIndicator
    }
}
