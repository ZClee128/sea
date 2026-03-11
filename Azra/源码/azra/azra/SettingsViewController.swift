import UIKit

class SettingsViewController: UITableViewController {

    // Section 0: Coin balance / Buy Coins
    // Section 1: App settings
    let settingsItems = [
//        ("Rate Us", "star"),
        ("Clear Cache", "trash"),
        ("Privacy Policy", "lock.doc"),
        ("Terms of Service", "doc.text"),
        ("About Azra", "info.circle")
    ]
    
    private var coinObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.tableFooterView = UIView()
        
        // Refresh coin display when balance changes
        coinObserver = NotificationCenter.default.addObserver(forName: CoinManager.balanceChangedNotification, object: nil, queue: .main) { [weak self] _ in
            self?.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    deinit {
        coinObserver.map { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Coins" : "App"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : settingsItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        if indexPath.section == 0 {
            // Coin Balance Cell
            cell.textLabel?.text = "Buy Coins"
            cell.imageView?.image = UIImage(systemName: "bitcoinsign.circle.fill")
            cell.imageView?.tintColor = .systemYellow
            cell.detailTextLabel?.text = nil
            // Show balance as detail
            let badge = UILabel()
            badge.text = "\(CoinManager.shared.balance) coins"
            badge.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            badge.textColor = .secondaryLabel
            badge.sizeToFit()
            cell.accessoryView = badge
        } else {
            let item = settingsItems[indexPath.row]
            cell.textLabel?.text = item.0
            cell.imageView?.image = UIImage(systemName: item.1)
            cell.imageView?.tintColor = .systemIndigo
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let storeVC = CoinStoreViewController()
            navigationController?.pushViewController(storeVC, animated: true)
            return
        }
        
        let item = settingsItems[indexPath.row].0
        
        switch item {
        case "Rate Us":
            // Replace with your real App Store URL after submission
            if let url = URL(string: "https://apps.apple.com/app") {
                UIApplication.shared.open(url)
            }
            
        case "Clear Cache":
            // Clear the ImageVault disk cache
            let fm = FileManager.default
            if let dir = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
                let vaultDir = dir.appendingPathComponent("ImageVault")
                try? fm.removeItem(at: vaultDir)
            }
            let alert = UIAlertController(title: "Cache Cleared", message: "All cached files have been removed.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            
        case "Privacy Policy":
            let detail = SettingsDetailViewController(title: "Privacy Policy", content: """
Azra Privacy Policy
Last Updated: March 2026

1. Information We Collect
Azra does not collect personal identifying information. All tattoo designs you generate are stored locally on your device only. We do not transmit your prompts or generated images to external servers.

2. AI Studio & Image Generation
Text prompts you enter in the AI Studio are processed to generate images. Prompts and generated images are not stored on our servers or used to train AI models. All generation history is local to your device.

3. Camera & Photo Library
Camera access is used solely for the Tattoo Try-On AR feature. Photo Library access is used solely to save your composite preview images when you explicitly tap Save. We never access your existing photos without your explicit action.

4. Analytics
We may collect anonymized, aggregated usage statistics (e.g., which features are used most often). This data cannot be used to identify you.

5. Third-Party Services
Azra does not include third-party advertising SDKs. If third-party AI generation APIs are used, their respective privacy policies will apply to data sent to their servers.

6. Children's Privacy
Azra is rated 18+ and is not directed to children under 13. We do not knowingly collect data from minors.

7. Contact
Questions about this policy? Email: nguyenthiyennhi0324@icloud.com
""")
            navigationController?.pushViewController(detail, animated: true)
            
        case "Terms of Service":
            let detail = SettingsDetailViewController(title: "Terms of Service", content: """
Azra Terms of Service
Last Updated: March 2026

By downloading or using Azra, you agree to these Terms. If you do not agree, do not use the app.

1. Eligibility
You must be at least 17 years old to use Azra.

2. AI-Generated Content Policy
Azra's AI Studio generates tattoo designs from your text prompts. You agree NOT to use this feature to generate:

• Sexually explicit content of any kind
• Any content that sexually exploits or depicts minors (CSAM) — this is a crime and will be reported to law enforcement
• Graphic violence, gore, or content glorifying self-harm or suicide
• Content promoting or threatening violence against any person or group
• Defamatory or harassing content about real individuals
• Content targeting individuals based on race, religion, gender, sexual orientation, nationality, or disability
• Content that infringes any third party's intellectual property, copyright, or trademark rights (including brand mascots or copyrighted characters)
• Disinformation or content intended to deceive or impersonate others

Azra reserves the right to terminate access for users who violate these rules.

3. User Responsibility
You are solely responsible for the prompts you submit and the content you generate. AI-generated designs are for personal reference and artistic inspiration only. Azra is not responsible for any physical tattoos you receive based on these designs.

4. Disclaimer of Warranties
The app is provided "as is." We make no guarantees about the accuracy, quality, or appropriateness of AI-generated designs.

5. Limitation of Liability
To the maximum extent permitted by law, Azra and its developers shall not be liable for any indirect, incidental, or consequential damages arising from your use of the app.

6. Reporting Violations
To report content that violates these Terms, contact: nguyenthiyennhi0324@icloud.com

7. Changes to Terms
We may update these Terms from time to time. Continued use after changes constitutes acceptance.
""")
            navigationController?.pushViewController(detail, animated: true)
            
        case "About Azra":
            let detail = SettingsDetailViewController(title: "About Azra", content: """
Azra — Ink Your Vision

Version 1.0.0

Azra is your personal AI-powered tattoo design studio. Whether you're dreaming of fine-line minimalism, bold tribal patterns, or photorealistic portraits, Azra helps you visualize, design, and try on tattoo art before committing to the needle.

Features
• Explore a curated library of tattoo styles
• Generate custom AI tattoo designs from text prompts
• Preview designs on your body using AR Try-On
• Save your favorite designs to your personal Ink Vault

Designed for tattoo enthusiasts, artists, and the tattoo-curious.

Made with ❤️ for iOS 13 and above.
""")
            navigationController?.pushViewController(detail, animated: true)
            
        default:
            break
        }
    }
}

/// Reusable text content viewer for Settings detail pages
class SettingsDetailViewController: UIViewController {
    
    private let textContent: String
    
    init(title: String, content: String) {
        self.textContent = content
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let label = UILabel()
        label.text = textContent
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(label)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            label.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            label.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
}
