//
//  MyVideioViewCell.swift
//  FrogHouse
//
//  Created by 서정원 on 9/9/25.
//

import UIKit

final class HistoryCardCell: UICollectionViewCell {
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor.FH.backgroundBase.color
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.FH.title(size: 14)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
    }
    
    private func configureUI() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        thumbnailImageView.anchor
            .top(contentView.topAnchor)
            .leading(contentView.leadingAnchor)
            .trailing(contentView.trailingAnchor)
            .height(100)

        titleLabel.anchor
            .top(thumbnailImageView.bottomAnchor, offset: 4)
            .leading(contentView.leadingAnchor, offset: 4)
            .trailing(contentView.trailingAnchor, offset: 4)
            .bottom(contentView.bottomAnchor, offset: 4)
    }
}

extension HistoryCardCell {
    func configureUI(title: String, thumbnailImageURL: URL?) {
        titleLabel.text = title
        
        let placeholder = UIImage(systemName: "photo.fill")
        thumbnailImageView.kf.setImage(with: thumbnailImageURL, placeholder: placeholder)
    }
}