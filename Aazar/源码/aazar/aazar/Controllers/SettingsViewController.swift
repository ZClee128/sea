import UIKit

class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let options = ["⭐️ My Coins", "Version Info", "Clear Cache", "Privacy Policy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Settings"
        
        setupTableView()
        
        // Listen for balance updates
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: CoinManager.balanceDidChangeNotification, object: nil)
    }
    
    @objc private func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = options[indexPath.row]
        
        if indexPath.row == 0 { // My Coins
            cell.textLabel?.textColor = .systemYellow
            cell.textLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            cell.detailTextLabel?.text = "\(CoinManager.shared.currentBalance)"
            cell.detailTextLabel?.textColor = .label
            cell.detailTextLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            cell.accessoryType = .disclosureIndicator
        } else if indexPath.row == 1 { // Version Info
            cell.detailTextLabel?.text = "1.0.0"
            cell.selectionStyle = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 { // Store
            let storeVC = StoreViewController()
            storeVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(storeVC, animated: true)
        } else if indexPath.row == 2 { // Clear Cache
            let alert = UIAlertController(title: "Cache Cleared", message: "Image cache has been cleared.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else if indexPath.row == 3 { // Privacy Policy
            let policyVC = UIViewController()
            policyVC.view.backgroundColor = .systemBackground
            policyVC.title = "Privacy Policy"
            
            let textView = UITextView()
            textView.isEditable = false
            textView.font = .systemFont(ofSize: 16)
            textView.text = """
            Privacy Policy
            
            Last updated: March 11, 2026
            
            1. Information Collection
            TrendBoard is a local utility application. We do NOT collect, store, or transmit any of your personal data, images, or behaviors to any external servers. All moodboard generation and color extraction are processed entirely on your device locally.
            
            2. Photo Library Access
            We request access to your Photo Library solely for the purpose of saving the Moodboard collages you manually generate within the App. We do not read or scan your existing photo library.
            
            3. Local Storage
            Your 'Favorites' list and agreement status are saved directly inside your device's local UserDefaults.
            
            By continuing to use the App, you acknowledge and agree to these terms.
            """
            textView.translatesAutoresizingMaskIntoConstraints = false
            policyVC.view.addSubview(textView)
            
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: policyVC.view.safeAreaLayoutGuide.topAnchor, constant: 16),
                textView.leadingAnchor.constraint(equalTo: policyVC.view.leadingAnchor, constant: 16),
                textView.trailingAnchor.constraint(equalTo: policyVC.view.trailingAnchor, constant: -16),
                textView.bottomAnchor.constraint(equalTo: policyVC.view.safeAreaLayoutGuide.bottomAnchor)
            ])
            
            navigationController?.pushViewController(policyVC, animated: true)
        }
    }
}
