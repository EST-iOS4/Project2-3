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
        // MARK: Jay - 목록이 갱신되면 캐러셀 아이템 세팅 (비동기 로드 반영)
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
        
        // MARK: Jay - 현재 인덱스가 바뀌면 태그/접근성/스크롤 반영
        viewModel.onCurrentItemChanged = { [weak self] item, index, total in
            guard let self else { return }
            // MARK: Jay - 태그 갱신
            self.videoTagsView.setTags(item.tags)
            self.accessibilityLabel = "추천 비디오 \(index + 1)/\(total)"
            self.videoCarouselView.scroll(to: index, animated: true)
        }
    }
    
    override func setupUI() {
        navigationItem.title = "TOP 10 – 오늘 뭐 봐?"
        videoCarouselView.backgroundColor = .clear
        videoTagsView.backgroundColor = .clear
        // MARK: Jay - 캐러셀 페이지 변경시 → VM 인덱스 반영
        videoCarouselView.onPageChanged = { [weak self] newIndex in
            self?.viewModel.setCurrentIndex(newIndex)
        }
        
        // MARK: Jay - 캐러셀 탭 이벤트 델리게이트 연결
        videoCarouselView.delegate = self
    }
    
    override func setupLayouts() {
        view.addSubview(videoCarouselView)
        view.addSubview(videoTagsView)
    }
    
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
    
    // MARK: Jay - Core Data에서 Statistics.viewCount DESC 로 로드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
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

// MARK: Jay - RecommendedVideoCarouselView 에서 전달받은 탭 이벤트 처리
extension RecommendedVideoViewController: RecommendedVideoCarouselViewDelegate {
    func recommendedCarousel(_ view: RecommendedVideoCarouselView, didSelectItemAt index: Int) {
        guard let item = viewModel.item(at: index) else { return }
        let vc = VideoDetailViewController(viewModel: VideoDetailViewModel(id: item.id))
        navigationController?.pushViewController(vc, animated: true)
    }
}
