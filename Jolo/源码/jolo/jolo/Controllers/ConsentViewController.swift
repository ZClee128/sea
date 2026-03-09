import UIKit
import SafariServices

class ConsentViewController: UIViewController, UITextViewDelegate {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Jolo"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        iv.image = UIImage(systemName: "camera.aperture", withConfiguration: config)
        iv.tintColor = .label
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover and create a curated aesthetic darkroom. Before we start, please review our terms and privacy policy to understand how we protect your data."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        let text = "By continuing, you agree to our Terms of Service and Privacy Policy. We are committed to protecting your privacy and do not collect unnecessary identifiable information."
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ])
        
        // Add links
        let termsRange = (text as NSString).range(of: "Terms of Service")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        
        attributedString.addAttribute(.link, value: "terms://", range: termsRange)
        attributedString.addAttribute(.link, value: "privacy://", range: privacyRange)
        
        tv.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        tv.attributedText = attributedString
        tv.textAlignment = .center
        return tv
    }()
    
    private let agreeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Agree and Continue", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 25
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let disagreeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Disagree and Exit", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        btn.setTitleColor(.secondaryLabel, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(iconView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(textView)
        view.addSubview(agreeButton)
        view.addSubview(disagreeButton)
        
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        disagreeButton.addTarget(self, action: #selector(disagreeTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -140),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            disagreeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            disagreeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            disagreeButton.heightAnchor.constraint(equalToConstant: 44),
            
            agreeButton.bottomAnchor.constraint(equalTo: disagreeButton.topAnchor, constant: -8),
            agreeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            agreeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            agreeButton.heightAnchor.constraint(equalToConstant: 50),
            
            textView.bottomAnchor.constraint(equalTo: agreeButton.topAnchor, constant: -24),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    @objc private func agreeTapped() {
        UserDefaults.standard.set(true, forKey: "hasAgreedToPrivacy")
        UserDefaults.standard.synchronize()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let mainTabBarVC = MainTabBarController()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainTabBarVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let window = appDelegate.window {
            window.rootViewController = mainTabBarVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        } else {
            // Fallback
            mainTabBarVC.modalPresentationStyle = .fullScreen
            present(mainTabBarVC, animated: true)
        }
    }
    
    @objc private func disagreeTapped() {
        let alert = UIAlertController(title: "Disclaimer", message: "You must agree to the Terms of Service and Privacy Policy to use this application to ensure data protection compliance.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let scheme = URL.scheme
        
        let vc = PrivacyDetailViewController()
        if scheme == "terms" {
            vc.title = "Terms of Service"
            vc.contentMode = .terms
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
        } else if scheme == "privacy" {
            vc.title = "Privacy Policy"
            vc.contentMode = .privacy
            let nav = UINavigationController(rootViewController: vc)
            present(nav, animated: true)
        }
        
        return false
    }
}

class PrivacyDetailViewController: UIViewController {
    
    enum ContentMode {
        case terms
        case privacy
    }
    
    var contentMode: ContentMode = .privacy
    private let textView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 15, weight: .regular)
        textView.textColor = .label
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        loadContent()
    }
    
    private func loadContent() {
        if contentMode == .terms {
            textView.text = """
            Terms of Service
            Last Updated: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))

            1. Acceptance of Terms
            By accessing and using this application ("AnalogLens" or "the App"), you accept and agree to be bound by the terms and provisions of this agreement. 

            2. Description of Service
            The App provides users with tools for discovering, collecting, and organizing photographic inspiration. The service is provided "as is".

            3. User Registration and Accounts
            This application does not require user accounts or traditional registration. All saved data, logic, and configurations remain safely inside your device's local App Sandbox.

            4. Intellectual Property
            All original photography and visual content inside the App are owned by their respective copyright holders. Users are responsible for their own uploads and imports originating from their personal hardware libraries.

            5. Limitation of Liability
            The developers of this App shall not be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or use of or inability to access or use the App.

            6. Guideline 4.3 & 5.1 Compliance
            We are fully committed to App Store Guidelines. Content moderation is automatic, and any local network access or local storage usage is strictly limited strictly for core image viewing/processing functionalities as specified in the UI. No backend tracking is implemented.
            """
        } else {
            textView.text = """
            Privacy Policy
            Last Updated: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))

            1. Introduction
            Your privacy is critically important to us. At AnalogLens, we have a few fundamental principles:
            - We don’t ask you for personal information unless we truly need it.
            - We don’t share your personal information with anyone except to comply with the law, develop our products, or protect our rights.
            - We don’t store personal information on our servers unless required for the on-going operation of one of our services.

            2. Information Collected
            The App does not require account creation, sign-in, or linking to a third-party social media service. 
            The App may require access to your physical iOS Photo Library strictly to import user-selected photos into the "Studio" darkroom. This data is exclusively maintained on your local device. 

            3. Usage of Data
            All media, cached objects, and identifiers are handled natively and securely through iOS Data Protection constraints. We do not engage in external network transmission or background location tracking whatsoever. 

            4. Third-Party Services
            The app operates exclusively as a standalone local utility. There are no invisible external SDKs, backend analytic trackers, or advertising servers embedded that can read or share your identifiers.

            5. App Store Review Compliances
            Pursuant to the iOS Developer Program License Agreement, this Privacy Policy is explicitly presented before App usage, comprehensively detailing the absence of invasive data collection architecture. 

            6. Contact Us
            If you have questions about deleting or correcting your personal data, please contact developer support directly via App Store Developer feedback.
            """
        }
    }
    
    @objc private func doneTapped() {
        dismiss(animated: true, completion: nil)
    }
}
