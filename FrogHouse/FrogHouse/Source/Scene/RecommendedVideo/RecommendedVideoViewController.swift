//
//  RecommendedVideoViewController.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit

final class RecommendedVideoViewController: BaseViewController<RecommendedVideoViewModel> {
    private let videoCarouselView = RecommendedVideoCarouselView()
    private let videoTagsView = VideoTagListView(alignment: .left)
    override func bind() {
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
        viewModel.onCurrentItemChanged = { [weak self] item, index, total in
            guard let self else { return }
            self.videoTagsView.setTags(item.categories.map { $0.title })
            self.accessibilityLabel = "추천 비디오 \(index + 1)/\(total)"
            self.videoCarouselView.scroll(to: index, animated: true)
        }
    }
    override func setupUI() {
        super.setupUI()
        navigationItem.title = "TOP 10 – 오늘 뭐 봐?"
        videoCarouselView.backgroundColor = .clear
        videoTagsView.backgroundColor = .clear
        videoCarouselView.onPageChanged = { [weak self] newIndex in
            self?.viewModel.setCurrentIndex(newIndex)
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCarouselView.startAutoScroll(interval: 3.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoCarouselView.stopAutoScroll()
    }
}

extension RecommendedVideoViewController: RecommendedVideoCarouselViewDelegate {
    func recommendedCarousel(_ view: RecommendedVideoCarouselView, didSelectItemAt index: Int) {
        guard let item = viewModel.item(at: index) else { return }
        let vc = VideoDetailViewController(viewModel: VideoDetailViewModel(id: item.id))
        navigationController?.pushViewController(vc, animated: true)
    }
}
