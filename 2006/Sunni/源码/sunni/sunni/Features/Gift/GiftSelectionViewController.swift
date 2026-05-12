//
//  GiftSelectionViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class GiftSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedGift: Gift?
    var onGiftSelected: ((Gift) -> Void)?
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Send Gift"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let itemWidth = (view.bounds.width - 80) / 3
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(GiftCell.self, forCellWithReuseIdentifier: GiftCell.identifier)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send Gift", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .appGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.isEnabled = false
        btn.alpha = 0.5
        return btn
    }()
    
    private let gifts = Gift.catalog
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        setupUI()
        updateBalanceLabel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(handleBar)
        containerView.addSubview(titleLabel)
        containerView.addSubview(balanceLabel)
        containerView.addSubview(collectionView)
        containerView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 500),
            
            handleBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            handleBar.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 5),
            
            titleLabel.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            balanceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            balanceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            balanceLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: sendButton.topAnchor, constant: -16),
            
            sendButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            sendButton.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        collectionView.delegate = self
        collectionView.dataSource = self
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }
    
    private func updateBalanceLabel() {
        let balance = AuthService.shared.authState.currentUser?.coinBalance ?? 0
        balanceLabel.text = "🪙 Your Balance: \(balance) coins"
    }
    
    // MARK: - Actions
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        // Only dismiss if tapping outside the containerView
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
    
    @objc private func handleSend() {
        guard let gift = selectedGift else { return }
        
        let balance = AuthService.shared.authState.currentUser?.coinBalance ?? 0
        if balance < gift.coinCost {
            showInsufficientBalanceAlert()
            return
        }
        
        onGiftSelected?(gift)
        dismiss(animated: true)
    }
    
    private func showInsufficientBalanceAlert() {
        let alert = UIAlertController(
            title: "Insufficient Balance",
            message: "You don't have enough coins to send this gift. Would you like to buy more?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Buy Coins", style: .default) { [weak self] _ in
            self?.dismiss(animated: true) {
                // Navigate to IAP page
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController as? UITabBarController,
                   let navController = rootVC.selectedViewController as? UINavigationController {
                    let iapVC = InAppPurchaseViewController()
                    navController.pushViewController(iapVC, animated: true)
                }
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate & DataSource
extension GiftSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GiftCell.identifier,
            for: indexPath
        ) as? GiftCell else {
            return UICollectionViewCell()
        }
        
        let gift = gifts[indexPath.item]
        let isSelected = gift.id == selectedGift?.id
        cell.configure(with: gift, isSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedGift = gifts[indexPath.item]
        collectionView.reloadData()
        
        sendButton.isEnabled = true
        sendButton.alpha = 1.0
    }
}

// MARK: - Gift Cell
class GiftCell: UICollectionViewCell {
    static let identifier = "GiftCell"
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let costLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 12
        
        contentView.addSubview(iconLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(costLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            costLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            costLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            costLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with gift: Gift, isSelected: Bool) {
        iconLabel.text = gift.icon
        nameLabel.text = gift.name
        costLabel.text = "🪙 \(gift.coinCost)"
        
        if isSelected {
            contentView.backgroundColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 0.2)
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor.appGreen.cgColor
        } else {
            contentView.backgroundColor = .systemGray6
            contentView.layer.borderWidth = 0
        }
    }
}
