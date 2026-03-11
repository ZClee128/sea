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
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "In order to use TrendBoard, you must agree to our Terms of Service and Privacy Policy. We do not collect personally identifiable information. We value your artistic expression and privacy."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .systemFont(ofSize: 16)
        descriptionLabel.textColor = .secondaryLabel
        
        let agreeButton = UIButton(type: .system)
        agreeButton.setTitle("Agree & Continue", for: .normal)
        agreeButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        agreeButton.backgroundColor = .systemBlue
        agreeButton.setTitleColor(.white, for: .normal)
        agreeButton.layer.cornerRadius = 12
        agreeButton.addTarget(self, action: #selector(didTapAgree), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, agreeButton])
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
