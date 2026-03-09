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
            By accessing and using Jolo ("the App"), you accept and agree to be bound by these Terms of Service. If you do not agree, please do not use the App.

            2. Description of Service
            Jolo provides a curated community for discovering and sharing analog photography. Features include a community Discover feed, a Journal feed, and creative studio tools.

            3. Community Standards & Zero-Tolerance Policy
            Jolo has a ZERO TOLERANCE policy for objectionable or abusive content. By using this App, you agree that you will NOT post, upload, or share content that:
            - Is hateful, harassing, threatening, or discriminatory
            - Contains nudity, sexual content, graphic violence, or self-harm material
            - Violates any applicable law or third-party rights
            - Is spam, misleading, or constitutes unauthorized advertising

            Users who violate these standards will be removed from the platform. Jolo reserves the right to remove any content and eject any user without notice for violations of these standards. All reports of objectionable content will be acted upon within 24 hours.

            4. Content Reporting & Blocking
            The App provides mechanisms to:
            - Report objectionable content using the "Report Content" option on any post
            - Block abusive users using the "Block User" option on any post

            Upon receiving a report, we will review and take appropriate action within 24 hours, including content removal and account ejection.

            5. User Accounts & Data
            This App operates without traditional account registration. All local data remains within your device's App Sandbox.

            6. Intellectual Property
            All photography in the App is owned by its respective copyright holders. Users are solely responsible for any content they upload from their personal device.

            7. Limitation of Liability
            Jolo shall not be liable for any indirect, incidental, or consequential damages resulting from your use of the App.
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
