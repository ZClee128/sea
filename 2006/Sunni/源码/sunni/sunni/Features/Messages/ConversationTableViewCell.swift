//
//  ConversationTableViewCell.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    static let identifier = "ConversationTableViewCell"
    
    // MARK: - UI Components
    
    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 25 // 50x50
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messagePreviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let unreadIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .appGreen
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .default
        
        contentView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messagePreviewLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(unreadIndicator)
        
        NSLayoutConstraint.activate([
            // Avatar
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            // Name
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -8),
            
            // Time
            timeLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.widthAnchor.constraint(equalToConstant: 60),
            
            // Preview
            messagePreviewLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            messagePreviewLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messagePreviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            // Unread
            unreadIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            unreadIndicator.centerYAnchor.constraint(equalTo: messagePreviewLabel.centerYAnchor),
            unreadIndicator.widthAnchor.constraint(equalToConstant: 12),
            unreadIndicator.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with conversation: Conversation) {
        nameLabel.text = conversation.otherUser.displayName
        messagePreviewLabel.text = conversation.lastMessage?.content
        
        // Avatar
        let initial = String(conversation.otherUser.displayName.prefix(1)).uppercased()
        avatarLabel.text = initial
        
        // Date formatting
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(conversation.updatedAt) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "MM/dd"
        }
        timeLabel.text = formatter.string(from: conversation.updatedAt)
        
        // Unread check (mock)
        unreadIndicator.isHidden = conversation.unreadCount == 0
        if conversation.unreadCount > 0 {
            nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
            messagePreviewLabel.textColor = .label
            messagePreviewLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        } else {
             nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
             messagePreviewLabel.textColor = .secondaryLabel
             messagePreviewLabel.font = .systemFont(ofSize: 14, weight: .regular)
        }
    }
}
