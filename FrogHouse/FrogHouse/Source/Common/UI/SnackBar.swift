//
//  SnackBar.swift
//  FrogHouse
//
//  Created by 이건준 on 9/12/25.
//

import UIKit

protocol SnackBarPresentable {
    func show()
    func dismiss()
}

struct SnackBarStyle {
    /// 좌측 아이콘
    let icon: UIImage?
    /// 설명 문구
    let message: String
}

class SnackBar: UIView {
    private var bottomConstraint: NSLayoutConstraint?
    private let style: SnackBarStyle
    private let contextView: UIView
    private let duration: Duration
    private var dismissTimer: Timer?
    
    // MARK: - UI Components
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 3
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var iconImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = style.icon
        imageView.backgroundColor = .clear
        imageView.anchor.size(width: 24, height: 24)
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .FH.signatureGreen.color
        label.text = style.message
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Init
    required init(contextView: UIView, style: SnackBarStyle, duration: Duration) {
        self.contextView = contextView
        self.style = style
        self.duration = duration
        super.init(frame: .zero)
        
        setupUI()
        setUpGesture()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .FH.backgroundBase.color
        layer.cornerRadius = 8
        
        addSubview(contentStackView)
        contentStackView.anchor
            .top(topAnchor)
            .leading(leadingAnchor, offset: 13)
            .trailing(trailingAnchor, offset: 13)
            .bottom(bottomAnchor)
        
        if style.icon != nil {
            contentStackView.addArrangedSubview(iconImage)
        }
        contentStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func setUpGesture() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
        swipe.direction = .down
        self.addGestureRecognizer(swipe)
    }
    
    @objc private func swipeAction(_ sender: UISwipeGestureRecognizer) {
        dismiss()
    }
    
    private func animation(with offset: CGFloat, completion: ((Bool) -> Void)? = nil) {
        bottomConstraint?.constant = offset
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.7,
            options: [.curveEaseOut],
            animations: {
                self.contextView.layoutIfNeeded()
            },
            completion: completion
        )
    }
}

// MARK: - Public methods
extension SnackBar: SnackBarPresentable {
    static func make(in view: UIView, style: SnackBarStyle, duration: Duration) -> Self {
        view.subviews.filter { $0 is Self }.forEach { $0.removeFromSuperview() }
        return Self.init(contextView: view, style: style, duration: duration)
    }
    
    func show() {
        contextView.addSubview(self)
        
        self.anchor
            .leading(contextView.leadingAnchor, offset: 30)
            .trailing(contextView.trailingAnchor, offset: 30)
            .height(46)
        
        bottomConstraint = self.bottomAnchor.constraint(equalTo: contextView.safeAreaLayoutGuide.bottomAnchor, constant: 200)
        bottomConstraint?.isActive = true
        
        contextView.layoutIfNeeded()
        
        animation(with: -8) { _ in
            if self.duration != .infinite {
                self.dismissTimer = Timer.scheduledTimer(
                    timeInterval: TimeInterval(self.duration.value),
                    target: self,
                    selector: #selector(self.dismiss),
                    userInfo: nil,
                    repeats: false
                )
            }
        }
    }
    
    @objc func dismiss() {
        animation(with: 200) { _ in
            self.removeFromSuperview()
        }
        dismissTimer?.invalidate()
        dismissTimer = nil
    }
}

// MARK: - Duration
extension SnackBar {
    enum Duration: Equatable {
        case long, short, infinite, custom(CGFloat)
        var value: CGFloat {
            switch self {
            case .long: return 3.5
            case .short: return 2.0
            case .infinite: return -1
            case .custom(let duration): return duration
            }
        }
    }
}


