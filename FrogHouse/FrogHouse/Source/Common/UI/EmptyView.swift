//
//  EmptyView.swift
//  FrogHouse
//
//  Created by 이건준 on 9/9/25.
//

import UIKit

enum EmptyState {
    case noVideo
    case custom(icon: UIImage?, title: String, subtitle: String?)
    
    var icon: UIImage? {
        switch self {
        case .noVideo:
            return UIImage(systemName: "video.slash")
        case .custom(let icon, _, _):
            return icon
        }
    }
    
    var title: String {
        switch self {
        case .noVideo:
            return "콘텐츠가 없습니다"
        case .custom(_, let title, _):
            return title
        }
    }
    
    var subtitle: String? {
        switch self {
        case .noVideo:
            return "선택한 카테고리에 해당하는 비디오가 없습니다.\n다른 카테고리를 확인해보세요."
        case .custom(_, _, let subtitle):
            return subtitle
        }
    }
}

final class EmptyView: UIView {
    
    // MARK: - UI Components
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Init
    init(state: EmptyState) {
        super.init(frame: .zero)
        setupUI()
        setupLayouts()
        configure(with: state)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupLayouts()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        [iconImageView, titleLabel, subtitleLabel].forEach { addSubview($0) }
    }
    
    private func setupLayouts() {
        iconImageView.anchor
            .centerX(centerXAnchor)
            .centerY(centerYAnchor, offset: -60)
            .size(width: 80, height: 80)
        
        titleLabel.anchor
            .top(iconImageView.bottomAnchor, offset: 20)
            .leading(leadingAnchor, offset: 16)
            .trailing(trailingAnchor, offset: 16)
        
        subtitleLabel.anchor
            .top(titleLabel.bottomAnchor, offset: 8)
            .leading(leadingAnchor, offset: 32)
            .trailing(trailingAnchor, offset: 32)
    }
    
    // MARK: - Configure
    func configure(with state: EmptyState) {
        iconImageView.image = state.icon
        titleLabel.text = state.title
        subtitleLabel.text = state.subtitle
        subtitleLabel.isHidden = state.subtitle == nil
    }
}
