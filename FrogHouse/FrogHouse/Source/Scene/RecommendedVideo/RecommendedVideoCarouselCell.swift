//
//  RecommendedVideoCarouselCell.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

// MARK: Jay - Carousel 셀 (cellContainerView, 재생버튼, 불투명 오버레이영역(titleLabel+detailLabel)
final class RecommendedVideoCarouselCell: UICollectionViewCell {

    // MARK: Jay - Identifier
    // TODO: Jay - Enum으로 수정예정
    static let reuseID = "RecommendedVideoCarouselCell"

    // MARK: Jay - 테두리로 셀마다 다른효과 줄 경우 활용예정
    private let coloredBackgroundView: UIView = {
        let v = UIView()
        return v
    }()

    // MARK: Jay - 가장겉, 감싸는뷰 영역
    private let cellContainerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 15
        v.clipsToBounds = true
        return v
    }()

    // MARK: Jay - 비디오 썸네일 이미지
    private let videoImageThumbnailView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    // MARK: Jay - 재생버튼 영역
    private let overlayPlayButtonContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.layer.cornerRadius = 28
        v.clipsToBounds = true
        return v
    }()
    
    // MARK: Jay - 재생버튼
    // TODO: Jay - UIImageView >> 버튼으로 수정예정
    private let videoPlayButton: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "play.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: Jay - 텍스트라벨 영역
    private let overlayTextLabelContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        return v
    }()
    
    // MARK: Jay - 제목라벨
    private let videoTitleTextLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.lineBreakMode = .byTruncatingTail
        // MARK: Jay - Subheadline + Bold
        let base = UIFont.preferredFont(forTextStyle: .subheadline)
        lb.font = .systemFont(ofSize: base.pointSize, weight: .bold)
        lb.textColor = .white
        return lb
    }()

    // MARK: Jay - 상세설명라벨
    private let videoDetailTextLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.lineBreakMode = .byTruncatingTail
        lb.font = .preferredFont(forTextStyle: .subheadline)
        lb.textColor = .white.withAlphaComponent(0.9)
        return lb
    }()

    // MARK: Jay - 최소 높이 제약
    private var overlayMinHeightConstraint: NSLayoutConstraint?

    // MARK: Jay - Init
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

        // MARK: Jay - Constraints (AnchorWrapper 적용)
        coloredBackgroundView.anchor.edges(to: contentView)

        cellContainerView.anchor.edges(
            to: coloredBackgroundView,
            padding: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )

        videoImageThumbnailView.pinToSuperview()

        overlayPlayButtonContainer.anchor
            .centerX(videoImageThumbnailView.centerXAnchor)
            .centerY(videoImageThumbnailView.centerYAnchor)
            .width(56)
            .height(56)

        videoPlayButton.anchor
            .centerX(overlayPlayButtonContainer.centerXAnchor)
            .centerY(overlayPlayButtonContainer.centerYAnchor)
            .width(22)
            .height(22)

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

        // MARK: Jay - 텍스트라벨 영역의 최소 높이 계산
        let subLH = UIFont.preferredFont(forTextStyle: .subheadline).lineHeight
        let minOverlayHeight: CGFloat = 18 + subLH + 4 + subLH + 10
        overlayMinHeightConstraint = overlayTextLabelContainer.heightAnchor
            .constraint(greaterThanOrEqualToConstant: minOverlayHeight)
        overlayMinHeightConstraint?.isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Jay - Config
    func configure(with url: URL, title: String?, detail: String?) {
        videoImageThumbnailView.setImage(from: url)
        videoTitleTextLabel.text = title
        videoDetailTextLabel.text = detail
    }
}
