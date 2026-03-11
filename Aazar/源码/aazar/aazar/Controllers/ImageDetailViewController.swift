import UIKit

class ImageDetailViewController: UIViewController {
    let modeImage: MoodImage
    
    private let imageView = UIImageView()
    private let paletteStack = UIStackView()
    private let hexLabel = UILabel()
    private let noteTextView = UITextView()
    
    init(image: MoodImage) {
        self.modeImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Detail"
        setupUI()
        loadImage()
        loadNote()
        setupNavigationBar()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func loadNote() {
        let note = UserDefaults.standard.string(forKey: "note_\(modeImage.id)")
        noteTextView.text = note
        if note == nil || note!.isEmpty {
            noteTextView.text = "Write your inspirations here..."
            noteTextView.textColor = .tertiaryLabel
        }
    }
    
    private func setupNavigationBar() {
        let favBtn = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle"),
            style: .plain,
            target: self,
            action: #selector(showCollectionPicker)
        )
        
        let editBtn = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(openEditor)
        )
        
        navigationItem.rightBarButtonItems = [favBtn, editBtn]
    }
    
    @objc private func openEditor() {
        guard let currentImage = imageView.image else { return }
        let editorVC = PhotoEditorViewController(image: currentImage, model: modeImage)
        let nav = UINavigationController(rootViewController: editorVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc private func showCollectionPicker() {
        let collections = CollectionManager.shared.collections
        let ac = UIAlertController(title: "Add to Collection", message: "Choose a board to save this inspiration.", preferredStyle: .actionSheet)
        
        for collection in collections {
            let isSaved = CollectionManager.shared.isImage(modeImage.id, in: collection.id)
            let title = isSaved ? "✓ \(collection.name)" : collection.name
            
            ac.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
                if isSaved {
                    CollectionManager.shared.removeImage(self.modeImage.id, from: collection.id)
                } else {
                    CollectionManager.shared.addImage(self.modeImage.id, to: collection.id)
                }
            }))
        }
        
        ac.addAction(UIAlertAction(title: "+ Create New Board", style: .default, handler: { _ in
            self.showCreateBoardAlert()
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func showCreateBoardAlert() {
        let alert = UIAlertController(title: "New Board", message: "Enter a name for your new inspiration board.", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "E.g. Cyberpunk" }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                CollectionManager.shared.createCollection(name: text)
                // Add the current image to the newly created board
                if let newColl = CollectionManager.shared.collections.last {
                    CollectionManager.shared.addImage(self.modeImage.id, to: newColl.id)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let paletteTitle = UILabel()
        paletteTitle.text = "Color Palette"
        paletteTitle.font = .systemFont(ofSize: 18, weight: .bold)
        paletteTitle.translatesAutoresizingMaskIntoConstraints = false
        
        paletteStack.axis = .horizontal
        paletteStack.distribution = .fillEqually
        paletteStack.spacing = 8
        paletteStack.translatesAutoresizingMaskIntoConstraints = false
        
        hexLabel.text = "Tap a color to copy Hex"
        hexLabel.textColor = .secondaryLabel
        hexLabel.font = .systemFont(ofSize: 14)
        hexLabel.textAlignment = .center
        hexLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noteTextView.font = .systemFont(ofSize: 16)
        noteTextView.textColor = .label
        noteTextView.backgroundColor = .secondarySystemBackground
        noteTextView.layer.cornerRadius = 8
        noteTextView.delegate = self
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        
        let noteTitle = UILabel()
        noteTitle.text = "Inspirations & Notes"
        noteTitle.font = .systemFont(ofSize: 18, weight: .bold)
        noteTitle.translatesAutoresizingMaskIntoConstraints = false
        
        let container = UIStackView(arrangedSubviews: [paletteTitle, paletteStack, hexLabel, noteTitle, noteTextView])
        container.axis = .vertical
        container.spacing = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let mainStack = UIStackView(arrangedSubviews: [imageView, container])
        mainStack.axis = .vertical
        mainStack.spacing = 24
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            paletteStack.heightAnchor.constraint(equalToConstant: 60),
            noteTextView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func loadImage() {
        if let image = UIImage(named: modeImage.localImageName) {
            imageView.image = image
            let colors = image.extractDominantColors()
            buildPalette(with: colors)
        }
    }
    
    private func buildPalette(with colors: [UIColor]) {
        paletteStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for color in colors {
            let colorView = UIView()
            colorView.backgroundColor = color
            colorView.layer.cornerRadius = 8
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(colorTapped(_:)))
            colorView.addGestureRecognizer(tap)
            colorView.isUserInteractionEnabled = true
            
            paletteStack.addArrangedSubview(colorView)
        }
    }
    
    @objc private func colorTapped(_ recognizer: UITapGestureRecognizer) {
        guard let view = recognizer.view, let color = view.backgroundColor else { return }
        let hex = color.hexString
        UIPasteboard.general.string = hex
        
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = .identity
            }
        }
        
        hexLabel.text = "Copied \(hex)!"
        hexLabel.textColor = color
    }
}

extension ImageDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .tertiaryLabel {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your inspirations here..."
            textView.textColor = .tertiaryLabel
            UserDefaults.standard.removeObject(forKey: "note_\(modeImage.id)")
        } else {
            UserDefaults.standard.set(textView.text, forKey: "note_\(modeImage.id)")
        }
    }
}
