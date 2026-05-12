//
//  InAppPurchaseViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit
import StoreKit

struct CoinPackage {
    let productId: String
    let price: String
    let priceUSD: String
    let coins: Int
    let bonusInfo: String
}

class InAppPurchaseViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(CoinPackageCell.self, forCellReuseIdentifier: CoinPackageCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let coinPackages: [CoinPackage] = [
        CoinPackage(productId: "Sunni", price: "0.99", priceUSD: "$0.99", coins: 32, bonusInfo: "32 + 0 Bonus"),
        CoinPackage(productId: "Sunni1", price: "1.99", priceUSD: "$1.99", coins: 60, bonusInfo: "60 + 0 Bonus"),
        CoinPackage(productId: "Sunni2", price: "2.99", priceUSD: "$2.99", coins: 96, bonusInfo: "96 + 0 Bonus"),
        CoinPackage(productId: "Sunni4", price: "4.99", priceUSD: "$4.99", coins: 165, bonusInfo: "165 + 0 Bonus"),
        CoinPackage(productId: "Sunni5", price: "5.99", priceUSD: "$5.99", coins: 189, bonusInfo: "189 + 0 Bonus"),
        CoinPackage(productId: "Sunni9", price: "9.99", priceUSD: "$9.99", coins: 299, bonusInfo: "299 + 60 Bonus"),
        CoinPackage(productId: "Sunni19", price: "19.99", priceUSD: "$19.99", coins: 599, bonusInfo: "599 + 130 Bonus"),
        CoinPackage(productId: "Sunni49", price: "49.99", priceUSD: "$49.99", coins: 1599, bonusInfo: "1599 + 270 Bonus"),
        CoinPackage(productId: "Sunni99", price: "99.99", priceUSD: "$99.99", coins: 3199, bonusInfo: "3199 + 600 Bonus")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Purchase Coins"
        
        setupUI()
        loadProducts()
        
        // Listen for purchase success
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePurchaseSuccess(_:)),
            name: NSNotification.Name("PurchaseSuccess"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func loadProducts() {
        if #available(iOS 15.0, *) {
            Task {
                do {
                    let _ = try await IAPService.shared.fetchProducts()
                    print("✅ Products loaded successfully")
                } catch {
                    print("❌ Failed to load products: \(error)")
                    showError("Failed to load products. Please try again later.")
                }
            }
        } else {
            // iOS 13-14: Mock IAP
            print("🔷 iOS 13-14: Using mock IAP")
        }
    }
    
    @objc private func handlePurchaseSuccess(_ notification: Notification) {
        guard let coins = notification.object as? Int else { return }
        
        let alert = UIAlertController(
            title: "Purchase Successful! 🎉",
            message: "You received \(coins) coins!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension InAppPurchaseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinPackages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoinPackageCell.identifier, for: indexPath) as? CoinPackageCell else {
            return UITableViewCell()
        }
        
        cell.configure(with: coinPackages[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let package = coinPackages[indexPath.row]
        
        let alert = UIAlertController(
            title: "Purchase Coins",
            message: "Purchase \(package.coins) coins for \(package.priceUSD)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Buy", style: .default) { [weak self] _ in
            self?.handlePurchase(package: package)
        })
        
        present(alert, animated: true)
    }
    
    private func handlePurchase(package: CoinPackage) {
        if #available(iOS 15.0, *) {
            // iOS 15+: Real StoreKit 2
            handleRealPurchase(package: package)
        } else {
            // iOS 13-14: Mock purchase (auto-succeed)
            handleMockPurchase(package: package)
        }
    }
    
    @available(iOS 15.0, *)
    private func handleRealPurchase(package: CoinPackage) {
        // Show loading indicator
        let loadingAlert = UIAlertController(title: nil, message: "Processing purchase...", preferredStyle: .alert)
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        loadingAlert.view.addSubview(indicator)
        indicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor).isActive = true
        indicator.topAnchor.constraint(equalTo: loadingAlert.view.topAnchor, constant: 50).isActive = true
        present(loadingAlert, animated: true)
        
        Task {
            do {
                let success = try await IAPService.shared.purchase(productId: package.productId)
                
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        if success {
                            // Success notification will be shown via NotificationCenter
                            print("✅ Purchase successful")
                        } else {
                            let alert = UIAlertController(
                                title: "Purchase Cancelled",
                                message: "Your purchase was cancelled.",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert, animated: true)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    loadingAlert.dismiss(animated: true) {
                        let alert = UIAlertController(
                            title: "Purchase Failed",
                            message: error.localizedDescription,
                            preferredStyle: .alert
                        )
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    private func handleMockPurchase(package: CoinPackage) {
        // Auto-succeed for iOS 13-14 or simulator
        guard var user = AuthService.shared.authState.currentUser else { return }
        user.coinBalance += package.coins
        AuthService.shared.authState.currentUser = user
        
        // Save coin balance persistently
        AuthService.shared.saveCoinBalance(user.coinBalance, for: user.id)
        
        NotificationCenter.default.post(name: NSNotification.Name("UserDataUpdated"), object: nil)
        
        let alert = UIAlertController(
            title: "Purchase Successful! 🎉",
            message: "You received \(package.coins) coins!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class CoinPackageCell: UITableViewCell {
    static let identifier = "CoinPackageCell"
    
    private let coinLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bonusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .appGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(coinLabel)
        contentView.addSubview(bonusLabel)
        contentView.addSubview(priceLabel)
        
        NSLayoutConstraint.activate([
            coinLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            coinLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            bonusLabel.topAnchor.constraint(equalTo: coinLabel.bottomAnchor, constant: 4),
            bonusLabel.leadingAnchor.constraint(equalTo: coinLabel.leadingAnchor),
            bonusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            priceLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with package: CoinPackage) {
        coinLabel.text = "\(package.coins) coins"
        bonusLabel.text = package.bonusInfo
        priceLabel.text = package.priceUSD
    }
}
