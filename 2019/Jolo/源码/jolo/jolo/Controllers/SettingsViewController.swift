import UIKit
import SafariServices

class SettingsViewController: UITableViewController {
    
    enum SettingSection: Int, CaseIterable {
        case store
        case data
        case legal
        case info
        
        var title: String {
            switch self {
            case .store: return "Wallet & Coins"
            case .data: return "Data Management"
            case .legal: return "Legal"
            case .info: return "App Info"
            }
        }
    }
    
    enum StoreRow: Int, CaseIterable {
        case buyCoins
    }
    
    enum DataRow: Int, CaseIterable {
        case clearMoodboard
    }
    
    enum LegalRow: Int, CaseIterable {
        case privacyPolicy
        case termsOfService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Settings"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        NotificationCenter.default.addObserver(self, selector: #selector(balanceUpdated), name: NSNotification.Name("CoinBalanceChanged"), object: nil)
    }
    
    @objc private func balanceUpdated() {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingSection(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SettingSection(rawValue: section) {
        case .store?: return StoreRow.allCases.count
        case .data?: return DataRow.allCases.count
        case .legal?: return LegalRow.allCases.count
        case .info?: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.accessoryType = .none
        cell.textLabel?.textColor = .label
        cell.detailTextLabel?.text = nil
        
        if let section = SettingSection(rawValue: indexPath.section) {
            switch section {
            case .store:
                let row = StoreRow(rawValue: indexPath.row)!
                switch row {
                case .buyCoins:
                    cell = UITableViewCell(style: .value1, reuseIdentifier: "SettingsCell") // Need detail text
                    cell.textLabel?.text = "Get Coins"
                    cell.detailTextLabel?.text = "\(StoreManager.shared.coinBalance) \u{25CE}"
                    cell.detailTextLabel?.textColor = .systemOrange
                    cell.accessoryType = .disclosureIndicator
                }
            case .data:
                let row = DataRow(rawValue: indexPath.row)!
                switch row {
                case .clearMoodboard:
                    cell.textLabel?.text = "Clear Moodboard"
                    cell.textLabel?.textColor = .systemRed
                }
            case .legal:
                let row = LegalRow(rawValue: indexPath.row)!
                switch row {
                case .privacyPolicy:
                    cell.textLabel?.text = "Privacy Policy"
                    cell.accessoryType = .disclosureIndicator
                case .termsOfService:
                    cell.textLabel?.text = "Terms of Service"
                    cell.accessoryType = .disclosureIndicator
                }
            case .info:
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
                cell.textLabel?.text = "Version \(version)"
                cell.textLabel?.textColor = .gray
                cell.selectionStyle = .none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = SettingSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .store:
            let storeVC = StoreViewController()
            storeVC.modalPresentationStyle = .pageSheet
            present(storeVC, animated: true)
        case .data:
            let row = DataRow(rawValue: indexPath.row)!
            switch row {
            case .clearMoodboard:
                MoodboardManager.shared.clearAll()
                showAlert(title: "Success", message: "Moodboard history cleared.")
            }
        case .legal:
            let row = LegalRow(rawValue: indexPath.row)!
            let vc = PrivacyDetailViewController()
            switch row {
            case .privacyPolicy:
                vc.title = "Privacy Policy"
                vc.contentMode = .privacy
            case .termsOfService:
                vc.title = "Terms of Service"
                vc.contentMode = .terms
            }
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
        case .info:
            break
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
