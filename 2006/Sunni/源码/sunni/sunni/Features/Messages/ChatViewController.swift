//
//  ChatViewController.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class ChatViewController: UIViewController {
    
    private let otherUser: User
    private var messages: [Message] = []
    
    // MARK: - UI Components
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.register(MessageBubbleCell.self, forCellReuseIdentifier: MessageBubbleCell.identifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .systemBackground
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Type a message..."
        tf.font = .systemFont(ofSize: 16)
        tf.borderStyle = .none
        tf.backgroundColor = UIColor(hex: "F5F5F5")
        tf.layer.cornerRadius = 20
        tf.clipsToBounds = true
        
        // Padding
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.rightView = paddingView
        tf.rightViewMode = .always
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config)
        btn.setImage(image, for: .normal)
        btn.tintColor = .appGreen
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No messages yet.\nSay hello! 👋"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Constraint for keyboard handling
    private var bottomConstraint: NSLayoutConstraint?

    
    // MARK: - Init
    
    init(otherUser: User) {
        self.otherUser = otherUser
        super.init(nibName: nil, bundle: nil)
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = otherUser.displayName
        
        setupUI()
        loadMessages()
        setupKeyboardObservers()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(messageTextField)
        inputContainerView.addSubview(sendButton)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        
        // Manual constraint for keyboard handling
        bottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            // Input Container
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Height is determined by content + padding
            
            // Text Field
            messageTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: 12),
            messageTextField.bottomAnchor.constraint(equalTo: inputContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            messageTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 16),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            // Send Button
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -16),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor),
            
            // Empty State
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageBubbleCell.self, forCellReuseIdentifier: "MessageBubbleCell")
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    }
    
    private func setupKeyboardObservers() {
        // Keyboard observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func loadMessages() {
        // Load messages from service
        messages = MessageService.shared.getMessages(for: otherUser)
        
        // Update empty state
        if messages.isEmpty {
            emptyStateLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleSend() {
        guard let text = messageTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newMessage = Message(
            id: UUID(),
            conversationId: UUID().uuidString,
            senderId: AuthService.shared.authState.currentUser?.id ?? UUID(),
            receiverId: otherUser.id,
            content: text,
            type: .text,
            isRead: false,
            createdAt: Date()
        )
        
        messages.append(newMessage)
        
        // Update global state via MessageService
        MessageService.shared.sendMessage(to: otherUser, content: text)
        
        // Handle Empty State Transition
        if messages.count == 1 {
            emptyStateLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            // Standard update
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        scrollToBottom()
        messageTextField.text = ""
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            // Adjust constraint: move up by keyboard height
            // We pin to view.bottom, keyboardFrame is from bottom.
            // When visible, constant = -height
            bottomConstraint?.constant = -keyboardFrame.height
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        // Reset to bottom
        bottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - UITableView

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageBubbleCell.identifier, for: indexPath) as? MessageBubbleCell else {
            return UITableViewCell()
        }
        
        let message = messages[indexPath.row]
        let currentUserId = AuthService.shared.authState.currentUser?.id
        let isFromCurrentUser = message.senderId == currentUserId
        
        // If currentUserId is nil (unlikely if logged in), assume received for safety or handle gracefully
        // For simulation, if senderID matches our fake "sent" logic
        
        // Improved logic for demo:
        // In loadMessages we set senderId as UUID() for "me" messages. 
        // Real auth needs matching IDs. 
        // For this demo let's verify if message.senderId == otherUser.id (received) vs (sent)
        
        let isActuallyFromOther = message.senderId == otherUser.id
        cell.configure(with: message, isCurrentUser: !isActuallyFromOther)
        
        return cell
    }
}
