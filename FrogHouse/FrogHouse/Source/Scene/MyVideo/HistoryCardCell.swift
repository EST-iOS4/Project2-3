//
//  MyVideioViewCell.swift
//  FrogHouse
//
//  Created by 서정원 on 9/9/25.
//

import UIKit

final class HistoryCardCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .quaternarySystemFill
        return iv
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        //TODO: 서정원 - 폰트 변경
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.anchor
            .top(contentView.topAnchor)
            .leading(contentView.leadingAnchor)
            .trailing(contentView.trailingAnchor)
        imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7).isActive = true
        
        titleLabel.anchor
            .top(imageView.bottomAnchor, offset: 8)
            .leading(contentView.leadingAnchor, offset: 8)
            .trailing(contentView.trailingAnchor, offset: 8)
            .bottom(contentView.bottomAnchor, offset: 8)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }
    
    //TODO: 서정원 - 네트워크 통신을 통해 받아와야 함
    func configure(with model: HistoryItem) {
        titleLabel.text = model.title
        imageView.image = UIImage(systemName: "play.rectangle.fill")
        //TODO: - 서정원 폰트 변경
        imageView.tintColor = .tertiaryLabel
    }
}
