import UIKit

class ExploreDetailViewController: UIViewController {

    let styleTitle: String
    let styleDescription: String
    let headerColor: UIColor

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let heroImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let ctaButton = UIButton(type: .system)

    init(styleTitle: String, styleDescription: String, headerColor: UIColor) {
        self.styleTitle = styleTitle
        self.styleDescription = styleDescription
        self.headerColor = headerColor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Setup Navigation Bar
        navigationItem.largeTitleDisplayMode = .never
        
        setupUI()
    }

    private func setupUI() {
        // ScrollView Setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Hero Image setup
        if let image = UIImage(named: styleTitle) {
            heroImageView.image = image
            heroImageView.backgroundColor = .clear
        } else {
            heroImageView.image = nil
            heroImageView.backgroundColor = headerColor
        }
        
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heroImageView)

        // Title Setup
        titleLabel.text = styleTitle
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // Description Setup
        descriptionLabel.text = styleDescription
        descriptionLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0
        descriptionLabel.setLineSpacing(lineSpacing: 8.0)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)

        // Call to Action Setup
        ctaButton.setTitle("Create \(styleTitle) Tattoo", for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.backgroundColor = .black
        ctaButton.layer.cornerRadius = 25
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)
        contentView.addSubview(ctaButton)

        // Constraints
        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: 400), // Large hero image

            titleLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            ctaButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            ctaButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ctaButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            ctaButton.heightAnchor.constraint(equalToConstant: 50),
            ctaButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    @objc private func ctaTapped() {
        // Jump to Design Tab (index 1)
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
}

extension UILabel {
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        self.attributedText = attributedString
    }
}
