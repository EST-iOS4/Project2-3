//
//  AutoSizingCollectionView.swift
//  FrogHouse
//
//  Created by 이건준 on 9/9/25.
//

import UIKit

final class AutoSizingCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
}
