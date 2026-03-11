import UIKit

class DesignViewController: UIViewController, UITextViewDelegate {

    private let coinCostPerGeneration = 10  // Each generation costs 10 coins
    
    let promptTextView = UITextView()
    let generateButton = UIButton(type: .system)
    let placeholderLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    private let coinLabel = UILabel()
    private var coinObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AI Studio"
        view.backgroundColor = .systemBackground
        setupUI()
        updateCoinLabel()
        
        coinObserver = NotificationCenter.default.addObserver(forName: CoinManager.balanceChangedNotification, object: nil, queue: .main) { [weak self] _ in
            self?.updateCoinLabel()
        }
    }
    
    deinit {
        coinObserver.map { NotificationCenter.default.removeObserver($0) }
    }
    
    private func updateCoinLabel() {
        coinLabel.text = "💰 \(CoinManager.shared.balance) coins  (costs \(coinCostPerGeneration)/gen)"
    }

    private func setupUI() {
        // Descriptive Header
        let headerLabel = UILabel()
        headerLabel.text = "Describe your dream tattoo"
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)

        // TextView
        promptTextView.font = UIFont.systemFont(ofSize: 16)
        promptTextView.layer.borderWidth = 1
        promptTextView.layer.borderColor = UIColor.systemGray4.cgColor
        promptTextView.layer.cornerRadius = 8
        promptTextView.delegate = self
        promptTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promptTextView)

        // Placeholder
        placeholderLabel.text = "e.g., A minimalist geometric wolf howling at the moon, fine line style..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = .lightGray
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        promptTextView.addSubview(placeholderLabel)

        // Generate Button
        generateButton.setTitle("Generate Masterpiece", for: .normal)
        generateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        generateButton.backgroundColor = .systemIndigo
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 12
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.addTarget(self, action: #selector(generateTapped), for: .touchUpInside)
        view.addSubview(generateButton)

        // Activity Indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        // Coin Balance Label
        coinLabel.font = UIFont.systemFont(ofSize: 13)
        coinLabel.textColor = .secondaryLabel
        coinLabel.textAlignment = .center
        coinLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coinLabel)

        // Constraints
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            promptTextView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            promptTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promptTextView.heightAnchor.constraint(equalToConstant: 120),

            placeholderLabel.topAnchor.constraint(equalTo: promptTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: promptTextView.leadingAnchor, constant: 8),
            placeholderLabel.widthAnchor.constraint(equalTo: promptTextView.widthAnchor, constant: -16),

            generateButton.topAnchor.constraint(equalTo: promptTextView.bottomAnchor, constant: 30),
            generateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            generateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            generateButton.heightAnchor.constraint(equalToConstant: 50),
            
            coinLabel.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 10),
            coinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            coinLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    @objc private func generateTapped() {
        guard let text = promptTextView.text, !text.isEmpty else {
            let alert = UIAlertController(title: "Empty Prompt", message: "Please describe what you want the AI to create.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Check coin balance
        guard CoinManager.shared.balance >= coinCostPerGeneration else {
            let alert = UIAlertController(
                title: "Not Enough Coins",
                message: "You need \(coinCostPerGeneration) coins to generate a design. You have \(CoinManager.shared.balance) coins. Get more in Settings → Buy Coins.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Buy Coins", style: .default) { [weak self] _ in
                self?.tabBarController?.selectedIndex = 3   // Settings tab
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
            return
        }
        
        promptTextView.resignFirstResponder()
        generateButton.isEnabled = false
        generateButton.backgroundColor = .systemGray
        activityIndicator.startAnimating()
        
        // Simulating AI generation API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.generateButton.isEnabled = true
            self.generateButton.backgroundColor = .systemIndigo
            
            // Mock generating a solid color image block acting as a tattoo
            let mockImage = self.createMockImage()
            let imageName = "Tattoo_\(Int(Date().timeIntervalSince1970))"
            
            if ImageVaultManager.shared.saveImage(mockImage, withName: imageName) {
                // Deduct coins for this generation
                _ = CoinManager.shared.spend(self.coinCostPerGeneration)
                
                let alert = UIAlertController(title: "Generated Successfully!", message: "Your tattoo design has been saved to My Ink vault.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "View Vault", style: .default, handler: { _ in
                    self.tabBarController?.selectedIndex = 2
                }))
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
                self.promptTextView.text = ""
                self.placeholderLabel.isHidden = false
            }
        }
    }
    
    private func createMockImage() -> UIImage {
        // Randomly fetch imported image (missing 7 in Assets)
        let randomIndex = [1, 2, 3, 4, 5, 6, 8].randomElement() ?? 1
        if let image = UIImage(named: "\(randomIndex)") {
            return image
        }
        
        // Fallback shape if images not imported correctly
        let size = CGSize(width: 512, height: 512)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.darkGray.setFill()
        UIRectFill(rect)
        // Add some random shapes to simulate "art"
        UIColor.white.setStroke()
        let path = UIBezierPath(ovalIn: CGRect(x: 100, y: 100, width: 312, height: 312))
        path.lineWidth = 5
        path.stroke()
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? UIImage()
    }
}
