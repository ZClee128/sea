//
//  EmailInputViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class EmailInputViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Sunni"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email to continue"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .appGreen
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var isTermsAccepted = false

    private lazy var termsCheckbox: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        btn.setImage(UIImage(systemName: "square", withConfiguration: config), for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.square.fill", withConfiguration: config), for: .selected)
        btn.tintColor = .appGreen
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(toggleTerms), for: .touchUpInside)
        return btn
    }()
    
    private let termsButton: UIButton = {
        let btn = UIButton(type: .system)
        let text = "Terms of Service"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        btn.setAttributedTitle(attributedString, for: .normal)
        btn.setTitleColor(.secondaryLabel, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let eulaLabel: UILabel = {
        let label = UILabel()
        label.text = "I agree to the Terms of Use (EULA) and acknowledge that there is no tolerance for objectionable content or abusive users."
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Welcome"
        
        setupUI()
        setupActions()
        
        // Setup Close Button if Modal
        if navigationController?.presentingViewController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(handleClose))
        }
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(continueButton)
        view.addSubview(errorLabel)
        view.addSubview(termsCheckbox)
        view.addSubview(eulaLabel)
        view.addSubview(termsButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            continueButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            // Terms Layout
            termsCheckbox.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            termsCheckbox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            termsCheckbox.widthAnchor.constraint(equalToConstant: 24),
            termsCheckbox.heightAnchor.constraint(equalToConstant: 24),
            
            eulaLabel.topAnchor.constraint(equalTo: termsCheckbox.topAnchor),
            eulaLabel.leadingAnchor.constraint(equalTo: termsCheckbox.trailingAnchor, constant: 8),
            eulaLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            termsButton.topAnchor.constraint(equalTo: eulaLabel.bottomAnchor, constant: 4),
            termsButton.leadingAnchor.constraint(equalTo: eulaLabel.leadingAnchor)
        ])
    }
    
    private func setupActions() {
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(handleTerms), for: .touchUpInside)
        emailTextField.delegate = self
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func handleClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleContinue() {
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        
        guard isTermsAccepted else {
            showError("Please agree to the Terms of Service")
            // Shake animation
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.duration = 0.6
            animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
            termsCheckbox.layer.add(animation, forKey: "shake")
            return
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            showError("Please enter a valid email address")
            return
        }
        
        errorLabel.isHidden = true
        
        // Check if email exists
        let authService = AuthService.shared
        if authService.checkEmailExists(email) {
            // Show login
            let loginVC = LoginViewController(email: email)
            navigationController?.pushViewController(loginVC, animated: true)
        } else {
            // Show register
            let registerVC = RegisterViewController(email: email)
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }
    
    @objc private func toggleTerms() {
        isTermsAccepted.toggle()
        termsCheckbox.isSelected = isTermsAccepted
    }
    
    @objc private func handleTerms() {
        let alert = UIAlertController(title: "Terms of Service", message: """
        End User License Agreement (EULA)

        1. Acceptance of Terms
        By accessing and using this app, you accept and agree to be bound by the terms and provision of this agreement.

        2. User Content
        You are responsible for any content you post. We do not tolerate objectionable content or abusive users.
        
        3. No Tolerance Policy
        We strictly prohibit content that is unlawful, defamatory, obscene, offensive, or otherwise objectionable. Abusive behavior, harassment, and hate speech are not tolerated.
        
        4. Termination
        We reserve the right to ban users who violate these terms.
        """, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - UITextFieldDelegate

extension EmailInputViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleContinue()
        return true
    }
}
