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
        configureUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureUI() {
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(actionButton)
        
        container.pinToSuperview()
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.anchor
            .top(container.topAnchor)
            .leading(container.leadingAnchor)
            .bottom(container.bottomAnchor)
        
        actionButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        actionButton.setTitleColor(UIColor.FH.signatureGreen.color, for: .normal)
        
        actionButton.anchor
            .top(container.topAnchor)
            .trailing(container.trailingAnchor)
            .bottom(container.bottomAnchor)
            .leading(titleLabel.trailingAnchor)
        
        actionButton.addTarget(self, action: #selector(tapAction), for: .touchUpInside)
    }
    
    @objc private func tapAction() { actionHandler?() }
}

extension SectionHeaderView {
    func setTrailingActionTitle(_ title: String?, handler: (() -> Void)?) {
        actionButton.setTitle(title, for: .normal)
        actionButton.isHidden = (title == nil)
        actionHandler = handler
    }
}
