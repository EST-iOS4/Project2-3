//
//  VideoCell.swift
//  FrogHouse
//
//  Created by SJS on 9/5/25.
//

import Combine
import UIKit

import Kingfisher

final class VideoCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: VideoCell.self)
    
    private var cancellables = Set<AnyCancellable>()
    var onLikeTapped: (() -> Void)?
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.FH.backgroundBase.color
        imageView.image = UIImage(systemName: "video")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.FH.title(size: 20)
        label.textColor = UIColor.FH.primary.color
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.FH.body(size: 15)
        label.textColor = UIColor.FH.secondary.color
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        bind()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor =  UIColor.FH.backgroundBase.color
        
        [thumbnailImageView, likeButton, titleLabel, descriptionLabel].forEach { contentView.addSubview($0) }
    }
    
    private func setupConstraints() {
        thumbnailImageView.anchor
            .top(contentView.topAnchor)
            .leading(contentView.leadingAnchor)
            .bottom(contentView.bottomAnchor)
            .width(120)
        
        likeButton.anchor
            .top(titleLabel.topAnchor)
            .trailing(contentView.trailingAnchor)
            .size(width: 24, height: 24)
        
        titleLabel.anchor
            .top(contentView.topAnchor, offset: 5)
            .leading(thumbnailImageView.trailingAnchor, offset: 12)
            .trailing(likeButton.leadingAnchor, offset: 8)
        
        descriptionLabel.anchor
            .top(titleLabel.bottomAnchor, offset: 8)
            .leading(titleLabel.leadingAnchor)
            .trailing(contentView.trailingAnchor)
    }
    
    private func bind() {
        likeButton.publisher(for: .touchUpInside)
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: false)
            .sink { [weak self] _ in
                HapticManager.shared.hapticImpact(style: .light)
                self?.onLikeTapped?()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Configure Cell
extension VideoCell {
    func configure(
        title: String,
        description: String,
        isLiked: Bool,
        thumbnailImageURL: URL?
    ) {
        titleLabel.text = title
        descriptionLabel.text = description
        updateState(isLiked)
        thumbnailImageView.kf.setImage(with: thumbnailImageURL)
    }
    
    func updateState(_ liked: Bool) {
        let buttonImage = UIImage(systemName: liked ? "heart.fill" : "heart")
        let buttonColor: UIColor = liked ? UIColor.FH.emphasis.color :  UIColor.FH.primary.color  

        likeButton.setImage(buttonImage, for: .normal)
        likeButton.tintColor = buttonColor
    }
}
