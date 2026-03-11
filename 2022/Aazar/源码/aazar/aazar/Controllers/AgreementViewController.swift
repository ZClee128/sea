import UIKit

class AgreementViewController: UIViewController {

    var onAgreed: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        let titleLabel = UILabel()
        titleLabel.text = "Terms & Privacy"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        textView.delegate = self
        
        let text = "In order to use Aazar, you must agree to our Terms of Service and Privacy Policy. We do not collect personally identifiable information. We value your artistic expression and privacy."
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: text.count))
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        
        // Add links
        let termsRange = (text as NSString).range(of: "Terms of Service")
        let privacyRange = (text as NSString).range(of: "Privacy Policy")
        
        attributedString.addAttribute(.link, value: "aazar://terms", range: termsRange)
        attributedString.addAttribute(.link, value: "aazar://privacy", range: privacyRange)
        
        textView.attributedText = attributedString
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let agreeButton = UIButton(type: .system)
        agreeButton.setTitle("Agree & Continue", for: .normal)
        agreeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        agreeButton.backgroundColor = .systemBlue
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.layer.cornerRadius = 12
        agreeButton.addTarget(self, action: #selector(didTapAgree), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textView, agreeButton])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            agreeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func didTapAgree() {
        UserDefaults.standard.set(true, forKey: "hasAgreedToTerms")
        onAgreed?()
    }
}

extension AgreementViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let title: String
        let message: String
        
        if URL.scheme == "aazar" && URL.host == "terms" {
            title = "Terms of Service"
            message = """
            TERMS OF SERVICE
            
            Last updated: March 11, 2026
            
            1. Acceptance of Terms
            By accessing or using the Aazar app, you agree to be bound by these Terms. If you disagree with any part of the terms, then you may not access the Service.
            
            2. App Purpose and Content
            Aazar provides tools for visual inspiration, color palette extraction, and photo editing. You are responsible for the images you import, edit, and export using our tools.
            
            3. In-App Purchases (IAP)
            Aazar offers virtual coins for unlocking premium masterclass content. All sales are final and non-refundable, managed in accordance with Apple's standard App Store guidelines.
            
            4. User Conduct
            You agree not to use the App for any unlawful purpose or to violate any international, federal, provincial or state regulations, rules, laws, or local ordinances.
            
            5. Intellectual Property
            The Service and its original content, features, and functionality are and will remain the exclusive property of Aazar and its licensors.
            
            6. Limitation of Liability
            In no event shall Aazar, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service.
            """
        } else if URL.scheme == "aazar" && URL.host == "privacy" {
            title = "Privacy Policy"
            message = """
            PRIVACY POLICY
            
            Last updated: March 11, 2026
            
            1. Information Collection and Use
            Aazar is designed as a local utility application. We do NOT collect, store, or transmit any of your personal data, images, or app usage behaviors to external servers. All moodboard generation, color extraction, and photo filtering are processed entirely locally on your device.
            
            2. Photo Library Access
            We request access to your Photo Library solely for the purpose of allowing you to save the images and moodboards you manually edit or generate within the App. We do not stealthily read or scan your photo library.
            
            3. Local Storage
            Your 'Favorites' list, saved folders, coin balance, and unlocked premium content metadata are saved directly inside your device's local secure storage (UserDefaults). If you delete the app, this data is cleared.
            
            4. Third-Party Services
            Transactions for virtual coins are handled securely by Apple via StoreKit. We do not have access to your credit card information or Apple ID credentials.
            
            5. Changes to This Privacy Policy
            We may update our Privacy Policy from time to time. You are advised to review this page periodically for any changes.
            """
        } else {
            return true
        }
        
        let detailVC = UIViewController()
        detailVC.view.backgroundColor = .systemBackground
        detailVC.title = title
        
        // Add a navigation bar since it's presented modally
        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.items = [UINavigationItem(title: title)]
        let closeItem = UIBarButtonItem(title: "Log", style: .done, target: nil, action: nil) // Mock action for aesthetics, we'll dismiss via actual gesture or button
        navBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissModal))
        detailVC.view.addSubview(navBar)
        
        let detailTextView = UITextView()
        detailTextView.isEditable = false
        detailTextView.font = .systemFont(ofSize: 16)
        detailTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        detailTextView.text = message
        detailTextView.translatesAutoresizingMaskIntoConstraints = false
        detailVC.view.addSubview(detailTextView)
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: detailVC.view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: detailVC.view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: detailVC.view.trailingAnchor),
            
            detailTextView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            detailTextView.leadingAnchor.constraint(equalTo: detailVC.view.leadingAnchor),
            detailTextView.trailingAnchor.constraint(equalTo: detailVC.view.trailingAnchor),
            detailTextView.bottomAnchor.constraint(equalTo: detailVC.view.bottomAnchor)
        ])
        
        // Temporarily store a reference to dismiss it
        objc_setAssociatedObject(self, &associatedModalKey, detailVC, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        present(detailVC, animated: true)
        return false
    }
    
    @objc private func dismissModal() {
        if let vc = objc_getAssociatedObject(self, &associatedModalKey) as? UIViewController {
            vc.dismiss(animated: true)
            objc_setAssociatedObject(self, &associatedModalKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private var associatedModalKey: UInt8 = 0
