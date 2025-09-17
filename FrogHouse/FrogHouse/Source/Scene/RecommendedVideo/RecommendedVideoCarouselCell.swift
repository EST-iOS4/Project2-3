//
//  RecommendedVideoCarouselCell.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

final class RecommendedVideoCarouselCell: UICollectionViewCell {

    static let reuseID = "RecommendedVideoCarouselCell"
    private let coloredBackgroundView: UIView = {
        let v = UIView()
        return v
    }()
    
    private let cellContainerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.clipsToBounds = true
        return v
    }()

    private let videoImageThumbnailView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    private let overlayPlayButtonContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        return v
    }()
    
    private let videoPlayButton: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "play.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let overlayTextLabelContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()
    
    private let videoTitleTextLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.lineBreakMode = .byTruncatingTail
        let base = UIFont.preferredFont(forTextStyle: .subheadline)
        lb.font = .systemFont(ofSize: base.pointSize, weight: .bold)
        lb.textColor = .white
        return lb
    }()

    private let videoDetailTextLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.lineBreakMode = .byTruncatingTail
        lb.font = .preferredFont(forTextStyle: .subheadline)
        lb.textColor = .white.withAlphaComponent(0.9)
        return lb
    }()

    private var overlayMinHeightConstraint: NSLayoutConstraint?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(coloredBackgroundView)
        coloredBackgroundView.addSubview(cellContainerView)
        cellContainerView.addSubview(videoImageThumbnailView)
        videoImageThumbnailView.addSubview(overlayPlayButtonContainer)
        overlayPlayButtonContainer.addSubview(videoPlayButton)
        videoImageThumbnailView.addSubview(overlayTextLabelContainer)
        overlayTextLabelContainer.addSubview(videoTitleTextLabel)
        overlayTextLabelContainer.addSubview(videoDetailTextLabel)
        coloredBackgroundView.anchor.edges(to: contentView)
        cellContainerView.anchor.edges(
            to: coloredBackgroundView,
            padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )

        videoImageThumbnailView.pinToSuperview()
        overlayPlayButtonContainer.anchor
            .centerX(videoImageThumbnailView.centerXAnchor)
            .centerY(videoImageThumbnailView.centerYAnchor)
            .width(80)
            .height(80)

        videoPlayButton.anchor
            .centerX(overlayPlayButtonContainer.centerXAnchor)
            .centerY(overlayPlayButtonContainer.centerYAnchor)
            .width(40)
            .height(40)

        overlayTextLabelContainer.anchor
            .leading(videoImageThumbnailView.leadingAnchor, offset: 8)
            .trailing(videoImageThumbnailView.trailingAnchor, offset: 8)
            .bottom(videoImageThumbnailView.bottomAnchor, offset: 12)

        videoTitleTextLabel.anchor
            .top(overlayTextLabelContainer.topAnchor, offset: 18)
            .leading(overlayTextLabelContainer.leadingAnchor, offset: 12)
            .trailing(overlayTextLabelContainer.trailingAnchor, offset: 12)

        videoDetailTextLabel.anchor
            .top(videoTitleTextLabel.bottomAnchor, offset: 4)
            .leading(overlayTextLabelContainer.leadingAnchor, offset: 12)
            .trailing(overlayTextLabelContainer.trailingAnchor, offset: 12)
            .bottom(overlayTextLabelContainer.bottomAnchor, offset: 10)

        let subLH = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
        let minOverlayHeight: CGFloat = 18 + subLH + 4 + subLH + 10
        overlayMinHeightConstraint = overlayTextLabelContainer.heightAnchor
            .constraint(greaterThanOrEqualToConstant: minOverlayHeight)
        overlayMinHeightConstraint?.isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with url: URL, title: String?, detail: String?) {
        videoImageThumbnailView.setImage(from: url)
        videoTitleTextLabel.text = title
        videoDetailTextLabel.text = detail
    }
}
