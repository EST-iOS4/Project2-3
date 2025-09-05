//
//  VideoCell.swift
//  FrogHouse
//
//  Created by SJS on 9/5/25.
//

import UIKit

final class VideoCell: UITableViewCell {
    static let reuseIdentifier = String(describing: VideoCell.self)

    var onLikeTapped: (() -> Void)?
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let likeButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
        
            setupUI()
            setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.backgroundColor = .tertiarySystemFill     // TODO : 송지석 (색상 추후 교체)
        thumbnailImageView.image = UIImage(systemName: "video")
        
        titleLabel.font = UIFont.FH.title(size: 20)
        titleLabel.textColor = .label   // TODO : 송지석 (색상 추후 교체)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        
        descriptionLabel.font = UIFont.FH.body(size: 15)
        descriptionLabel.textColor = .secondaryLabel    // TODO : 송지석 (색상 추후 교체)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        let heart = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular, scale: .medium)
        likeButton.setPreferredSymbolConfiguration(heart, forImageIn: .normal)
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        
        // TODO : 송지석 (색상 추후 교체)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        [thumbnailImageView, likeButton, titleLabel, descriptionLabel].forEach { contentView.addSubview($0) }
    }
    
    private func setupConstraints() {
        let guide = contentView.layoutMarginsGuide
        let spacing: CGFloat = 8
        
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail

        descriptionLabel.numberOfLines = 2
        descriptionLabel.lineBreakMode = .byTruncatingTail
        
        thumbnailImageView.anchor
            .leading(guide.leadingAnchor)
            .centerY(guide.centerYAnchor)
            .size(width: 120, height: 80)

        likeButton.anchor
            .top(guide.topAnchor)
            .trailing(guide.trailingAnchor)
            .size(width: 24, height: 24)
        
        titleLabel.anchor
            .top(guide.topAnchor)
            .leading(thumbnailImageView.trailingAnchor, offset: 12)
            .trailing(likeButton.leadingAnchor, offset: 8)
        
        descriptionLabel.anchor
            .top(titleLabel.bottomAnchor, offset: spacing)
            .leading(titleLabel.leadingAnchor)
            .trailing(guide.trailingAnchor)
            .bottom(guide.bottomAnchor)
        
        likeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    @objc private func didTapLike() { onLikeTapped?() }
    
    func configure(title: String, desc: String, liked: Bool) {
        titleLabel.text = title
        descriptionLabel.text  = desc
        setLiked(liked, animated: false)
    }
    
    func setLiked(_ liked: Bool, animated: Bool = true) {
        let img = UIImage(systemName: liked ? "heart.fill" : "heart")
        if animated {
            UIView.transition(with: likeButton, duration: 0.12, options: .transitionCrossDissolve) {
                self.likeButton.setImage(img, for: .normal)
                self.likeButton.tintColor = liked ? .systemRed : .label     // TODO : 송지석 (색상 추후 교체)
            }
        } else {
            likeButton.setImage(img, for: .normal)
            likeButton.tintColor = liked ? .systemRed : .label // TODO : 송지석 (색상 추후 교체)
        }
    }
}
