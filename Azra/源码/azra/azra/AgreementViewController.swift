import UIKit

class AgreementViewController: UIViewController {

    let titleLabel = UILabel()
    let eulaTextView = UITextView()
    let agreeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        // Title
        titleLabel.text = "Privacy & Terms of Service"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // EULA TextView
        eulaTextView.text = """
        Welcome to Azra!

        Please read these Terms carefully before using the app. By tapping "Agree & Continue", you confirm that you are 17 years of age or older, and that you agree to be bound by the following terms.

        ─────────────────────────────
        1. AI-Generated Content Policy
        ─────────────────────────────
        Azra's AI Studio feature allows you to generate tattoo designs through text prompts. You agree that you will NOT use this feature to generate:

        • Sexually explicit or adult content of any kind
        • Any content that sexually exploits or depicts minors (CSAM). Such content is strictly illegal and will be reported to authorities.
        • Graphic violence, gore, or content glorifying self-harm
        • Content that depicts, promotes, or threatens violence against any individual or group
        • Defamatory, harassing, or hateful content targeting real individuals based on race, religion, gender, sexual orientation, or other protected characteristics
        • Content that infringes on the intellectual property, trademarks, or copyright of any third party (including copyrighted characters or brand logos)
        • Content intended to deceive, defraud, or impersonate any person or entity

        Azra employs automated safety filters. Violations may result in permanent account termination and may be reported to appropriate law enforcement authorities.

        ─────────────────────────────
        2. User Responsibility
        ─────────────────────────────
        You are solely responsible for all content you generate using Azra. AI-generated designs are for personal reference and artistic inspiration only. Azra is not liable for any physical tattoos you receive based on these designs.

        ─────────────────────────────
        3. Privacy Policy Highlights
        ─────────────────────────────
        • Azra does not collect or sell your personal data.
        • AI-generated images are processed and stored locally on your device.
        • We do not share your prompts or generated images with third parties.
        • Anonymous, aggregated usage statistics may be collected to improve the app.

        ─────────────────────────────
        4. Age Requirement
        ─────────────────────────────
        Azra is intended for users who are 17 years of age or older. By continuing, you confirm you meet this age requirement.

        ─────────────────────────────
        5. Reporting Violations
        ─────────────────────────────
        If you encounter content that violates these terms, please report it to: support@azra.app

        By tapping "Agree & Continue", you acknowledge you have read and agree to all of the above.
        """
        eulaTextView.font = UIFont.systemFont(ofSize: 14)
        eulaTextView.isEditable = false
        eulaTextView.translatesAutoresizingMaskIntoConstraints = false
        eulaTextView.layer.borderWidth = 1
        eulaTextView.layer.borderColor = UIColor.systemGray4.cgColor
        eulaTextView.layer.cornerRadius = 8
        eulaTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.addSubview(eulaTextView)

        // Agree Button
        agreeButton.setTitle("Agree & Continue", for: .normal)
        agreeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        agreeButton.backgroundColor = .systemBlue
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.layer.cornerRadius = 12
        agreeButton.translatesAutoresizingMaskIntoConstraints = false
        agreeButton.addTarget(self, action: #selector(agreeTapped), for: .touchUpInside)
        view.addSubview(agreeButton)

        // Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            eulaTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            eulaTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eulaTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eulaTextView.bottomAnchor.constraint(equalTo: agreeButton.topAnchor, constant: -20),

            agreeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            agreeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            agreeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            agreeButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func agreeTapped() {
        UserDefaults.standard.set(true, forKey: "HasAgreedToTerms")
        
        let rootVC = MainTabBarController()
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = rootVC
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }
}
