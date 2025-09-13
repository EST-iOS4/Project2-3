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
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        
        thumbnailImageView.anchor
            .top(contentView.topAnchor, offset: 8)
            .leading(contentView.leadingAnchor, offset: 8)
            .trailing(contentView.trailingAnchor, offset: 8)
        thumbnailImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 9.0 / 16.0).isActive = true
        
        titleLabel.anchor
            .top(thumbnailImageView.bottomAnchor, offset: 8)
            .leading(contentView.leadingAnchor, offset: 8)
            .trailing(contentView.trailingAnchor, offset: 8)
            .bottom(contentView.bottomAnchor, offset: 8)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
    }
    
    func configure(with model: MyVideoViewModel.HistoryItem) {
        titleLabel.text = model.title
        
        let placeholder = UIImage(systemName: "photo.fill")
        thumbnailImageView.kf.setImage(with: model.thumbnailURL,
                                       placeholder: placeholder,
                                       options: [.transition(.fade(0.2))])
    }
}
