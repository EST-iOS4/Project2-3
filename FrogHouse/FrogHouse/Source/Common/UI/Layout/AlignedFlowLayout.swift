//
//  AlignedFlowLayout.swift
//  FrogHouse
//
//  Created by 이건준 on 9/16/25.
//

import UIKit

final class AlignedFlowLayout: UICollectionViewFlowLayout {
    var alignment: TagAlignment = .left

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }

        var adjustedAttributes: [UICollectionViewLayoutAttributes] = []
        var currentLineAttributes: [UICollectionViewLayoutAttributes] = []
        var currentY: CGFloat = -1

        for attr in attributes {
            guard attr.representedElementCategory == .cell else {
                adjustedAttributes.append(attr)
                continue
            }

            if currentY == -1 || abs(attr.frame.origin.y - currentY) > 1 {
                applyAlignment(to: currentLineAttributes)
                adjustedAttributes.append(contentsOf: currentLineAttributes)

                currentLineAttributes.removeAll()
                currentY = attr.frame.origin.y
            }
            currentLineAttributes.append(attr)
        }

        applyAlignment(to: currentLineAttributes)
        adjustedAttributes.append(contentsOf: currentLineAttributes)

        return adjustedAttributes
    }

    private func applyAlignment(to attributes: [UICollectionViewLayoutAttributes]) {
        guard alignment == .center, let collectionView = collectionView else { return }

        let totalWidth = attributes.reduce(0) { $0 + $1.frame.width } +
                         CGFloat(attributes.count - 1) * minimumInteritemSpacing
        let inset = (collectionView.bounds.width - totalWidth) / 2

        var x = inset
        for attr in attributes {
            var frame = attr.frame
            frame.origin.x = x
            attr.frame = frame
            x += frame.width + minimumInteritemSpacing
        }
    }
}
