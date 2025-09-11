//
//  RecommendedVideoViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

final class RecommendedVideoViewController: BaseViewController<RecommendedVideoViewModel> {

    // MARK: Jay - Carousel 형태의 비디오 컬렉션뷰
    private let videoCarouselView = RecommendedVideoCarouselView()

    // MARK: Jay - 비디오 태그 리스트뷰
    private let videoTagsView = VideoTagListView()

    override func bind() {
        viewModel.onCurrentItemChanged = { [weak self] item, index, total in
            guard let self else { return }
            // MARK: Jay - 태그 갱신
            self.videoTagsView.setTags(item.tags)
            self.accessibilityLabel = "추천 비디오 \(index + 1)/\(total)"
            self.videoCarouselView.scroll(to: index, animated: true)
        }
    }

    override func setupUI() {
        view.backgroundColor = .systemBackground

        // MARK: Jay - Carousel 아이템 데이터 구성 (url + title + detail)
        let carouselItems: [RecommendedCarouselItem] = viewModel.items.map {
            RecommendedCarouselItem(videoThumbnailURL: $0.thumbnailURL, videoTitle: $0.title, videoDetail: $0.detail)
        }
        videoCarouselView.setItems(carouselItems)

        // MARK: Jay - 캐러셀 페이지 변경시 → VM 인덱스 반영
        videoCarouselView.onPageChanged = { [weak self] newIndex in
            self?.viewModel.setCurrentIndex(newIndex)
        }
        
        if let item = viewModel.item(at: viewModel.currentIndex) {
            viewModel.onCurrentItemChanged?(item, viewModel.currentIndex, viewModel.items.count)
        }
    }

    override func setupLayouts() {
        view.addSubview(videoCarouselView)
        view.addSubview(videoTagsView)
    }

    override func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        videoCarouselView.anchor
            .top(safeArea.topAnchor, offset: 80)
            .leading(safeArea.leadingAnchor)
            .trailing(safeArea.trailingAnchor)
        videoCarouselView.heightAnchor.constraint(
            equalTo: videoCarouselView.widthAnchor,
            multiplier: 4.0/3.0
        ).isActive = true

        videoTagsView.anchor
            .top(videoCarouselView.bottomAnchor, offset: 16)
            .leading(safeArea.leadingAnchor, offset: 20)
            .trailing(safeArea.trailingAnchor, offset: 20)
    }

    // MARK: Jay - LifeCycle에 맞게 오토슬라이드 설정
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // MARK: Jay - 오토슬라이드 시작
        videoCarouselView.startAutoScroll(interval: 3.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // MARK: Jay - 오토슬라이드 정지
        videoCarouselView.stopAutoScroll()
    }
}
