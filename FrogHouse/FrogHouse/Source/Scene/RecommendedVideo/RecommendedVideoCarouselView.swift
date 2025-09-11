//
//  RecommendedVideoCarouselView.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

struct RecommendedCarouselItem: Hashable {
    // MARK: Jay - 데이터
    let videoThumbnailURL: URL
    let videoTitle: String?
    let videoDetail: String?
}

// MARK: Jay - 캐러셀 뷰 (스와이프, 오토슬라이드, 스와이프 시 오토슬라이드 일시정지 >> 0.5초 후 재개, 무한 캐러셀 + 프리페치 추가)
final class RecommendedVideoCarouselView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {

    // MARK: Jay - Outputs
    var onPageChanged: ((Int) -> Void)?

    // MARK: Jay - Data
    private var baseItems: [RecommendedCarouselItem] = []   // MARK: Jay - 원본 아이템
    private var baseCount: Int { baseItems.count }
    private let repeatFactor: Int = 3                       // MARK: Jay - 무한 캐러셀용 3배 확장
    private var totalItems: Int { baseCount * repeatFactor }
    
    // MARK: Jay - Index
    private var currentVirtualIndex: Int = 0                // MARK: Jay - 가상 인덱스(0..<totalItems)
    private var currentRealIndex: Int {                     // MARK: Jay - 실인덱스(0..<baseCount)
        guard baseCount > 0 else { return 0 }
        return currentVirtualIndex % baseCount
    }
    private var middleBlockStart: Int {                     // MARK: Jay - 가운데 블록 시작 인덱스
        return baseCount
    }

    // MARK: Jay - 오토슬라이드 3.0초 마다
    private var autoTimer: Timer?
    private var resumeWorkItem: DispatchWorkItem?
    private var autoInterval: TimeInterval = 3.0

    // MARK: Jay - Layout
    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 0
        l.minimumInteritemSpacing = 0
        return l
    }()

    // MARK: Jay - UI
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .normal
        cv.register(RecommendedVideoCarouselCell.self,
                    forCellWithReuseIdentifier: RecommendedVideoCarouselCell.reuseID)
        cv.delegate = self
        cv.dataSource = self
        cv.prefetchDataSource = self // MARK: Jay - 프리페치 등록
        return cv
    }()

    // MARK: Jay - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit {
        // MARK: Jay - 타이머/워크아이템 정리
        autoTimer?.invalidate()
        resumeWorkItem?.cancel()
    }

    // MARK: Jay - LayoutSubviews (셀 크기 조정)
    override func layoutSubviews() {
        super.layoutSubviews()
        let itemSize = CGSize(width: bounds.width, height: bounds.height)
        if layout.itemSize != itemSize {
            layout.itemSize = itemSize
            layout.invalidateLayout()
            // MARK: Jay - 크기 변경 시 현재 가상 인덱스로 재정렬 (무한 캐러셀)
            syncScroll(toVirtual: currentVirtualIndex, animated: false)
        }
    }

    // MARK: Jay - Public API
    func setItems(_ items: [RecommendedCarouselItem]) {
        self.baseItems = items
        collectionView.reloadData()

        guard baseCount > 0 else { return }

        // MARK: Jay - 가운데 블록에서 시작 (무한 캐러셀)
        currentVirtualIndex = middleBlockStart
        syncScroll(toVirtual: currentVirtualIndex, animated: false)

        // MARK: Jay - 첫 페이지 알림
        onPageChanged?(currentRealIndex)
        
        // MARK: Jay - 초기 프리페치 (무한 캐러셀 + 프리페치)
        prefetchAround(virtualIndex: currentVirtualIndex)
    }

    func scroll(to index: Int, animated: Bool) {
        guard baseCount > 0, (0..<baseCount).contains(index) else { return }
        // MARK: Jay - 외부에서 실인덱스를 주면 가운데 블록의 동일 위치로 스크롤 (무한 캐러셀)
        let targetVirtual = middleBlockStart + index
        currentVirtualIndex = targetVirtual
        syncScroll(toVirtual: targetVirtual, animated: animated)
        if !animated { onPageChanged?(currentRealIndex) }
        
        // MARK: Jay - 수동 스크롤 시에도 프리페치
        prefetchAround(virtualIndex: currentVirtualIndex)
    }

    // MARK: Jay - Auto Scroll Controls
    func startAutoScroll(interval: TimeInterval = 3.0) {
        autoInterval = interval
        stopAutoScroll()
        guard baseCount > 1 else { return }
        autoTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.autoTick()
        }
        if let autoTimer { RunLoop.main.add(autoTimer, forMode: .common) }
    }

    func stopAutoScroll() {
        autoTimer?.invalidate()
        autoTimer = nil
    }

    private func autoTick() {
        // MARK: Jay - 사용자 제스처/감속 중이면 스킵
        guard !collectionView.isDragging, !collectionView.isDecelerating else { return }
        guard baseCount > 1 else { return }
        let nextVirtual = currentVirtualIndex + 1
        currentVirtualIndex = nextVirtual
        syncScroll(toVirtual: nextVirtual, animated: true)
        
        // MARK: Jay - 자동 스크롤 시 프리페치
        prefetchAround(virtualIndex: nextVirtual)
    }

    // MARK: Jay - Resume Scheduling
    private func scheduleAutoResume(after delay: TimeInterval = 0.5) {
        // 기존 예약 취소 후 새로 예약 (디바운스)
        resumeWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            // 이미 타이머가 있다면 건너뜀
            if self.autoTimer == nil { self.startAutoScroll(interval: self.autoInterval) }
        }
        resumeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    // MARK: Jay - Helpers
    private func pageWidth() -> CGFloat { max(1, collectionView.bounds.width) }
    private func currentPage() -> Int {
        let x = collectionView.contentOffset.x
        let p = Int(round(x / pageWidth()))
        return max(0, min(p, max(0, totalItems - 1)))
    }

    // MARK: Jay - 가상 스크롤 동기화 + 경계 재중앙화 (무한 캐러셀)
    private func syncScroll(toVirtual vIndex: Int, animated: Bool) {
        guard totalItems > 0 else { return }
        let clamped = max(0, min(vIndex, totalItems - 1))
        let indexPath = IndexPath(item: clamped, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)

        if !animated {
            recenterIfNeeded(aroundVirtual: clamped)
        }
    }

    // MARK: Jay - 가장자리 진입 시 가운데 블록으로 재중앙화 (무한 캐러셀)
    private func recenterIfNeeded(aroundVirtual vIndex: Int? = nil) {
        guard baseCount > 0, totalItems >= baseCount * 3 else { return }
        let v = vIndex ?? currentPage()
        let real = v % baseCount

        if v < baseCount || v >= baseCount * 2 {
            let middle = middleBlockStart + real
            currentVirtualIndex = middle
            let ip = IndexPath(item: middle, section: 0)
            collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: false)
        }
    }
    
    // MARK: Jay - 프리페치 유틸 (무한 캐러셀 + 프리페치)
    private func prefetchAround(virtualIndex: Int) {
        guard baseCount > 0 else { return }
        let candidates = [
            virtualIndex - 2, virtualIndex - 1,
            virtualIndex,     virtualIndex + 1, virtualIndex + 2
        ].filter { $0 >= 0 && $0 < totalItems }
        
        let urls: [URL] = candidates.compactMap { idx in
            let real = idx % baseCount
            return baseItems[real].videoThumbnailURL
        }
        RecommendedVideoImageLoader.shared.prefetch(urls: urls)
    }

    // MARK: Jay - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // MARK: Jay - 아이템이 0/1개면 그대로, 2개 이상이면 3배 확장 (무한 캐러셀)
        return baseCount <= 1 ? baseCount : totalItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecommendedVideoCarouselCell.reuseID, for: indexPath
        ) as! RecommendedVideoCarouselCell

        let real = baseCount == 0 ? 0 : (indexPath.item % baseCount)
        if baseCount > 0 {
            let item = baseItems[real]
            cell.configure(with: item.videoThumbnailURL, title: item.videoTitle, detail: item.videoDetail)
        }
        return cell
    }

    // MARK: Jay - Prefetching (무한 캐러셀 + 프리페치)
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard baseCount > 0 else { return }
        let urls: [URL] = indexPaths.compactMap { indexPath in
            let real = indexPath.item % baseCount
            return baseItems[real].videoThumbnailURL
        }
        RecommendedVideoImageLoader.shared.prefetch(urls: urls)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        // MARK: Jay - 단순 캐시이므로 취소 로직 없음 (필요 시 구현 가능)
    }

    // MARK: Jay - Delegate (페이징 콜백 + 자동스크롤 일시정지/재개 + 무한 캐러셀 재중앙화)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // MARK: Jay - 사용자 스와이프 시작 → 즉시 일시정지
        stopAutoScroll()
        resumeWorkItem?.cancel()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // MARK: Jay - 감속 종료 → 페이지 확정 + 재중앙화 + 0.5초 후 재개
        let v = currentPage()
        currentVirtualIndex = v
        recenterIfNeeded(aroundVirtual: v)
        onPageChanged?(currentRealIndex)
        scheduleAutoResume(after: 0.5)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // MARK: Jay - 드래그 종료 (감속 여부에 따라 처리)
        if !decelerate {
            let v = currentPage()
            currentVirtualIndex = v
            recenterIfNeeded(aroundVirtual: v)
            onPageChanged?(currentRealIndex)
            scheduleAutoResume(after: 0.5)
        }
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // MARK: Jay - 자동 스크롤 애니메이션 종료 시 현재 페이지 확정 + 무한 캐러셀 재중앙화
        let v = currentPage()
        currentVirtualIndex = v
        recenterIfNeeded(aroundVirtual: v)
        onPageChanged?(currentRealIndex)
    }
}
