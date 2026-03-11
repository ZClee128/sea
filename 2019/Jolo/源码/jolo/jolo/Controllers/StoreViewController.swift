import UIKit
import StoreKit

class StoreViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Get Coins"
        label.font = .systemFont(ofSize: 28, weight: .black)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let restoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Restore", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = .tertiaryLabel
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private var tableView: UITableView!
    
    private var products: [SKProduct] = []
    
    // Developer Hardcoded list for App Store Connect UI Screenshots
    private let fallbackProducts = [
        ("Jolo", "32 Coins", "$0.99"),
        ("Jolo1", "60 Coins", "$1.99"),
        ("Jolo2", "96 Coins", "$2.99"),
        ("Jolo4", "155 Coins", "$4.99"),
        ("Jolo5", "189 Coins", "$5.99"),
        ("Jolo9", "359 Coins", "$9.99"),
        ("Jolo19", "729 Coins", "$19.99"),
        ("Jolo49", "1869 Coins", "$49.99"),
        ("Jolo99", "3799 Coins", "$99.99")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupViews()
        updateBalance()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance), name: NSNotification.Name("CoinBalanceChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseSuccess), name: NSNotification.Name("PurchaseSuccessful"), object: nil)
        
        loadProducts()
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(balanceLabel)
        view.addSubview(restoreButton)
        view.addSubview(closeButton)
        
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        
        // Large price tags in table view
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StoreCell.self, forCellReuseIdentifier: StoreCell.reuseIdentifier)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            balanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            balanceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            restoreButton.centerYAnchor.constraint(equalTo: balanceLabel.centerYAnchor),
            restoreButton.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadProducts() {
        self.products = StoreManager.shared.products
        if self.products.isEmpty {
            StoreManager.shared.fetchProducts()
            // Wait a moment and check again
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.products = StoreManager.shared.products
                self?.tableView.reloadData()
                
                if (self?.products.isEmpty == true) {
                    let alert = UIAlertController(title: "Store Unavailable", message: "Could not fetch products from App Store Connect. Ensure your Sandbox account is configured in Xcode.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc private func updateBalance() {
        balanceLabel.text = "Balance: \(StoreManager.shared.coinBalance) Coins"
    }
    
    @objc private func handlePurchaseSuccess() {
        let alert = UIAlertController(title: "Thank You!", message: "Your coins have been added to your balance.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func restoreTapped() {
        let alert = UIAlertController(title: "Restore", message: "Restoring purchases...", preferredStyle: .alert)
        present(alert, animated: true)
        
        StoreManager.shared.restorePurchases()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true) {
                let success = UIAlertController(title: "Restored", message: "Any previous non-consumable purchases have been restored.", preferredStyle: .alert)
                success.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(success, animated: true)
            }
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension StoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.isEmpty ? fallbackProducts.count : products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoreCell.reuseIdentifier, for: indexPath) as! StoreCell
        
        if products.isEmpty {
            let fallback = fallbackProducts[indexPath.row]
            cell.configureFallback(title: fallback.1, price: fallback.2)
        } else {
            let product = products[indexPath.row]
            cell.configure(with: product)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !products.isEmpty {
            let product = products[indexPath.row]
            StoreManager.shared.purchase(product)
        }
    }
}

class StoreCell: UITableViewCell {
    static let reuseIdentifier = "StoreCell"
    
    private let coinIcon: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iv.image = UIImage(systemName: "bitcoinsign.circle.fill", withConfiguration: config)
        iv.tintColor = .systemOrange
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 15
        btn.isUserInteractionEnabled = false // Allow cell to handle touches
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(coinIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(priceButton)
        
        NSLayoutConstraint.activate([
            coinIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coinIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coinIcon.widthAnchor.constraint(equalToConstant: 32),
            coinIcon.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: coinIcon.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            priceButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            priceButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceButton.widthAnchor.constraint(equalToConstant: 80),
            priceButton.heightAnchor.constraint(equalToConstant: 30),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with product: SKProduct) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        let priceString = formatter.string(from: product.price) ?? "$\(product.price)"
        
        let coins = StoreManager.shared.productDict[product.productIdentifier] ?? 0
        titleLabel.text = "\(coins) Coins"
        priceButton.setTitle(priceString, for: .normal)
    }
    
    func configureFallback(title: String, price: String) {
        titleLabel.text = title
        priceButton.setTitle(price, for: .normal)
    }
}
