//
//  VideoTagCell.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

final class VideoTagCell: UICollectionViewCell {
    static let reuseID = String(describing: VideoTagCell.self)
    
    private let label: PaddingLabel = {
        let lb = PaddingLabel(insets: UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        lb.font = .FH.amount(size: 13)
        lb.textColor = .FH.primary.color
        lb.backgroundColor = .FH.signatureGreen.color.withAlphaComponent(0.35)
        lb.layer.cornerRadius = 6
        lb.clipsToBounds = true
        lb.numberOfLines = 1
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.pinToSuperview()
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(text: String) {
        label.text = text
    }
}
