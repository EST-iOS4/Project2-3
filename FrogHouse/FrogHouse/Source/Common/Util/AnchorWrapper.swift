//
//  AnchorWrapper.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

final class AnchorWrapper {
    private let view: UIView
    
    init(_ view: UIView) {
        self.view = view
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @discardableResult
    func top(_ anchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> Self {
        view.topAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func leading(_ anchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> Self {
        view.leadingAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func trailing(_ anchor: NSLayoutXAxisAnchor, offset: CGFloat = 0) -> Self {
        view.trailingAnchor.constraint(equalTo: anchor, constant: -offset).isActive = true
        return self
    }
    
    @discardableResult
    func bottom(_ anchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> Self {
        view.bottomAnchor.constraint(equalTo: anchor, constant: -offset).isActive = true
        return self
    }
    
    @discardableResult
    func centerX(_ anchor: NSLayoutXAxisAnchor) -> Self {
        view.centerXAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func centerY(_ anchor: NSLayoutYAxisAnchor, offset: CGFloat = 0) -> Self {
        view.centerYAnchor.constraint(equalTo: anchor, constant: offset).isActive = true
        return self
    }
    
    @discardableResult
    func width(_ constant: CGFloat) -> Self {
        view.widthAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func width(_ anchor: NSLayoutDimension) -> Self {
        view.widthAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func height(_ constant: CGFloat) -> Self {
        view.heightAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    
    @discardableResult
    func size(width: CGFloat, height: CGFloat) -> Self {
        return self.width(width).height(height)
    }
    
    @discardableResult
    func edges(to view: UIView, padding: UIEdgeInsets = .zero) -> Self {
        return self.top(view.topAnchor, offset: padding.top)
            .leading(view.leadingAnchor, offset: padding.left)
            .trailing(view.trailingAnchor, offset: padding.right)
            .bottom(view.bottomAnchor, offset: padding.bottom)
    }
}

extension UIView {
    var anchor: AnchorWrapper {
        return AnchorWrapper(self)
    }
    
    @discardableResult
    func pinToSuperview(padding: UIEdgeInsets = .zero) -> Self {
        guard let superview = self.superview else { return self }
        self.anchor.edges(to: superview, padding: padding)
        return self
    }
}



