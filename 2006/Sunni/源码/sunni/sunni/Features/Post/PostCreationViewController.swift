//
//  PostCreationViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit
import PhotosUI

class PostCreationViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.keyboardDismissMode = .interactive
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mediaPreviewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 12
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let addMediaButton: UIButton = {
        let btn = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.image = UIImage(systemName: "photo.on.rectangle")
            config.title = " Select Photo/Video"
            config.baseBackgroundColor = .systemGray5
            config.baseForegroundColor = .label
            config.cornerStyle = .medium
            btn.configuration = config
        } else {
            btn.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
            btn.setTitle(" Select Photo/Video", for: .normal)
            btn.backgroundColor = .systemGray5
            btn.tintColor = .label
            btn.layer.cornerRadius = 8
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        }
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let captionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.backgroundColor = .systemGray6
        tv.layer.cornerRadius = 12
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Write a caption..."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationButton: UIButton = {
        let btn = UIButton(type: .system)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "location.fill")
            config.title = " Add Location"
            config.baseForegroundColor = .secondaryLabel
            btn.configuration = config
            btn.contentHorizontalAlignment = .leading
        } else {
            btn.setImage(UIImage(systemName: "location.fill"), for: .normal)
            btn.setTitle(" Add Location", for: .normal)
            btn.tintColor = .secondaryLabel
            btn.contentHorizontalAlignment = .left
        }
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Properties
    private var selectedImage: UIImage?
    private var selectedLocation: String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "New Post"
        
        setupNavigationBar()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        let postButton = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(handlePost))
        // tintColor for bar button item is handled by navigation bar tint usually, but here specifically:
        postButton.tintColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
        navigationItem.rightBarButtonItem = postButton
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(mediaPreviewImageView)
        contentView.addSubview(addMediaButton)
        contentView.addSubview(captionTextView)
        contentView.addSubview(placeholderLabel)
        contentView.addSubview(locationButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Media Preview Area
            mediaPreviewImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mediaPreviewImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mediaPreviewImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mediaPreviewImageView.heightAnchor.constraint(equalToConstant: 250),
            
            addMediaButton.centerYAnchor.constraint(equalTo: mediaPreviewImageView.centerYAnchor),
            addMediaButton.centerXAnchor.constraint(equalTo: mediaPreviewImageView.centerXAnchor),
            
            // Caption
            captionTextView.topAnchor.constraint(equalTo: mediaPreviewImageView.bottomAnchor, constant: 16),
            captionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            captionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            captionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            placeholderLabel.topAnchor.constraint(equalTo: captionTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: captionTextView.leadingAnchor, constant: 5),
            
            // Location
            locationButton.topAnchor.constraint(equalTo: captionTextView.bottomAnchor, constant: 16),
            locationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            locationButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupActions() {
        addMediaButton.addTarget(self, action: #selector(handleSelectMedia), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(handleLocationSelect), for: .touchUpInside)
        captionTextView.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectMedia))
        mediaPreviewImageView.addGestureRecognizer(tap)
        mediaPreviewImageView.isUserInteractionEnabled = true
    }
    
    // MARK: - Actions
    
    @objc private func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc private func handleLocationSelect() {
        let alert = UIAlertController(title: "Add Location", message: "Enter location name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "e.g. Paris, France"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let location = alert.textFields?.first?.text, !location.isEmpty {
                self?.selectedLocation = location
                self?.updateLocationButton()
            }
        })
        present(alert, animated: true)
    }
    
    private func updateLocationButton() {
        guard let location = selectedLocation else { return }
        if #available(iOS 15.0, *) {
            locationButton.configuration?.title = " " + location
            locationButton.configuration?.baseForegroundColor = .systemBlue
        } else {
            locationButton.setTitle(" " + location, for: .normal)
            locationButton.tintColor = .systemBlue
        }
    }
    
    @objc private func handlePost() {
        guard let image = selectedImage else {
            let alert = UIAlertController(title: "Missing Media", message: "Please select a photo or video to post.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        guard let currentUser = AuthService.shared.authState.currentUser else { return }
        
        // Show loading
        let alert = UIAlertController(title: nil, message: "Posting...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Save image locally
            let savedImageURL = MockDataService.shared.saveImage(image)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                alert.dismiss(animated: true) {
                    guard let self = self else { return }
                    
                    let finalMediaURL = savedImageURL ?? "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&q=80"
                    
                    let newPost = Post(
                        userId: currentUser.id,
                        type: .image,
                        caption: self.captionTextView.text == "Write a caption..." ? "" : self.captionTextView.text,
                        mediaURL: finalMediaURL,
                        location: self.selectedLocation,
                        likeCount: 0,
                        commentCount: 0,
                        createdAt: Date(),
                        user: currentUser
                    )
                    
                    MockDataService.shared.addPost(newPost)
                    
                    // Reset UI
                    self.selectedImage = nil
                    self.selectedLocation = nil
                    self.mediaPreviewImageView.image = nil
                    self.mediaPreviewImageView.isHidden = true
                    self.addMediaButton.isHidden = false
                    self.captionTextView.text = "Write a caption..."
                    self.placeholderLabel.isHidden = false
                    self.navigationItem.rightBarButtonItem?.isEnabled = false
                    
                    if #available(iOS 15.0, *) {
                         self.locationButton.configuration?.title = " Add Location"
                         self.locationButton.configuration?.baseForegroundColor = .secondaryLabel
                    } else {
                         self.locationButton.setTitle(" Add Location", for: .normal)
                         self.locationButton.tintColor = .secondaryLabel
                    }
                    
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: NSNotification.Name("RefreshFeed"), object: nil)
                    }
                }
            }
        }
    }
    
    @objc private func handleSelectMedia() {
        if #available(iOS 14.0, *) {
            var config = PHPickerConfiguration()
            config.selectionLimit = 1
            config.filter = .any(of: [.images, .videos])
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true)
        } else {
            // Fallback for iOS 13
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.mediaTypes = ["public.image", "public.movie"]
            present(picker, animated: true)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

@available(iOS 14.0, *)
extension PostCreationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self, let image = image as? UIImage else { return }
                DispatchQueue.main.async {
                    self.selectedImage = image
                    self.mediaPreviewImageView.image = image
                    self.addMediaButton.isHidden = true
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension PostCreationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            self.selectedImage = image
            self.mediaPreviewImageView.image = image
            self.addMediaButton.isHidden = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension PostCreationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
