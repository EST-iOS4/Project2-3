//
//  CollectionReusableView.swift
//  FrogHouse
//
//  Created by 서정원 on 9/10/25.
//

import UIKit

final class SectionHeaderView: UICollectionReusableView {
    private let container = UIView()
    private let titleLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    
    var headerText: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    private var actionHandler: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(actionButton)
        
        container.anchor
            .top(topAnchor)
            .leading(leadingAnchor)
            .trailing(trailingAnchor, offset: 16)
            .bottom(bottomAnchor)
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.anchor
            .top(container.topAnchor, offset: 8)
            .leading(container.leadingAnchor)
            .bottom(container.bottomAnchor, offset: 8)
        
        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.anchor
            .centerY(titleLabel.centerYAnchor)
            .trailing(container.trailingAnchor)
        
        actionButton.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setTrailingActionTitle(_ title: String?, handler: (() -> Void)?) {
        actionButton.setTitle(title, for: .normal)
        actionButton.isHidden = (title == nil)
        actionHandler = handler
    }
    
    @objc private func tapAction() { actionHandler?() }
}

