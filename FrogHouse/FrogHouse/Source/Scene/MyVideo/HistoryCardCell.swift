//
//  MyVideioViewCell.swift
//  FrogHouse
//
//  Created by 서정원 on 9/9/25.
//

import UIKit

final class HistoryCardCell: UICollectionViewCell {
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
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
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
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
        
        contentView.addSubview(containerStackView)
        [thumbnailImageView, titleLabel].forEach { containerStackView.addArrangedSubview($0) }
        
        containerStackView.pinToSuperview()
    }
}

extension HistoryCardCell {
    func configureUI(title: String, thumbnailImageURL: URL?) {
        titleLabel.text = title
        
        let placeholder = UIImage(systemName: "photo.fill")
        thumbnailImageView.kf.setImage(with: thumbnailImageURL, placeholder: placeholder)
    }
}
