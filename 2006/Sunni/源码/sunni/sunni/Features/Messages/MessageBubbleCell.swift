//
//  MessageBubbleCell.swift
//  Scenery
//
//  Created on 2026/1/14.
//

import UIKit

class MessageBubbleCell: UITableViewCell {
    static let identifier = "MessageBubbleCell"
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: 280)
        ])
    }
    
    func configure(with message: Message, isCurrentUser: Bool) {
        messageLabel.text = message.content
        
        // Remove existing horizontal constraints for bubbleView related to contentView
        contentView.constraints.forEach { constraint in
            if (constraint.firstItem as? UIView == bubbleView &&
                (constraint.firstAttribute == .leading || constraint.firstAttribute == .trailing)) ||
               (constraint.secondItem as? UIView == bubbleView &&
                (constraint.secondAttribute == .leading || constraint.secondAttribute == .trailing)) {
                constraint.isActive = false 
            }
        }
        
        if isCurrentUser {
            bubbleView.backgroundColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
            messageLabel.textColor = .white
            bubbleView.layer.cornerRadius = 18
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        } else {
            bubbleView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            messageLabel.textColor = .black
            bubbleView.layer.cornerRadius = 18
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        }
    }
}
