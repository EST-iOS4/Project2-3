//
//  VideoTagCell.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

// MARK: Jay - 태그 셀
final class VideoTagCell: UICollectionViewCell {
    
    // MARK: Jay - Identifier >> 수정예정
    static let reuseID = "RecommendedVideoTagCell"
    
    private let label: PaddingLabel = {
        let lb = PaddingLabel(insets: UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6))
        lb.font = .preferredFont(forTextStyle: .caption2)
        lb.textColor = .secondaryLabel
        lb.backgroundColor = .systemGreen.withAlphaComponent(0.12)
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
    
    // MARK: Jay - 한 줄 높이 계산 (기기별 폰트사이즈대응)
    static func singleLineHeightForCurrentStyle() -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .caption2)
        let labelHeight = ceil(font.lineHeight) + 2 + 2
        return labelHeight
    }
}
