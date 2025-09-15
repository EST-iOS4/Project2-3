//
//  RecommendedVideoViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

// MARK: Jay - 추천 비디오 화면 (BaseViewController 제네릭 기반)
final class RecommendedVideoViewController: BaseViewController<RecommendedVideoViewModel> {

    // MARK: Jay - 캐러셀/태그 뷰 (기존 코드 그대로)
    private let videoCarouselView = RecommendedVideoCarouselView()
    
    // MARK: Jay - 비디오 태그 리스트뷰
    private let videoTagsView = VideoTagListView(alignment: .left)
    
    override func bind() {
        // MARK: Jay - 목록 갱신 시 캐러셀 세팅
        viewModel.onListUpdated = { [weak self] models in
            let items = models.map {
                RecommendedCarouselItem(
                    videoThumbnailURL: $0.thumbnailURL,
                    videoTitle: $0.title,
                    videoDetail: $0.detail
                )
            }
            self?.videoCarouselView.setItems(items)
        }

        // MARK: Jay - 현재 인덱스 변경 시 UI 반영
        viewModel.onCurrentItemChanged = { [weak self] item, index, total in
            guard let self else { return }
            self.videoTagsView.setTags(item.tags)
            self.accessibilityLabel = "추천 비디오 \(index + 1)/\(total)"
            self.videoCarouselView.scroll(to: index, animated: true)
        }
    }

    // MARK: Jay - UI 설정
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "TOP 10 – 오늘 뭐 봐?"
        navigationController?.navigationBar.tintColor = UIColor.FH.primary.color
        videoCarouselView.backgroundColor = .clear
        videoTagsView.backgroundColor = .clear
        videoCarouselView.onPageChanged = { [weak self] newIndex in
            self?.viewModel.setCurrentIndex(newIndex)
        }
        videoCarouselView.delegate = self
    }

    // MARK: Jay - 레이아웃
    override func setupLayouts() {
        view.addSubview(videoCarouselView)
        view.addSubview(videoTagsView)
    }

    // MARK: Jay - 제약
    override func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide

        videoCarouselView.anchor
            .top(safeArea.topAnchor)
            .leading(safeArea.leadingAnchor)
            .trailing(safeArea.trailingAnchor)
        videoCarouselView.heightAnchor.constraint(
            equalTo: videoCarouselView.widthAnchor,
            multiplier: 4.0/3.0
        ).isActive = true

        videoTagsView.anchor
            .top(videoCarouselView.bottomAnchor, offset: 6)
            .leading(safeArea.leadingAnchor, offset: 20)
            .trailing(safeArea.trailingAnchor, offset: 20)
    }

    // MARK: Jay - viewDidLoad >> viewWillAppear로 변경
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: Jay - 오토 슬라이드 라이프사이클
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCarouselView.startAutoScroll(interval: 3.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoCarouselView.stopAutoScroll()
    }
}

// MARK: Jay - 캐러셀 셀 선택 처리
extension RecommendedVideoViewController: RecommendedVideoCarouselViewDelegate {
    func recommendedCarousel(_ view: RecommendedVideoCarouselView, didSelectItemAt index: Int) {
        guard let item = viewModel.item(at: index) else { return }
        let vc = VideoDetailViewController(viewModel: VideoDetailViewModel(id: item.id))
        navigationController?.pushViewController(vc, animated: true)
    }
}
