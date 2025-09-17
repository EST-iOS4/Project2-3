//
//  RecommendedVideoCarouselView.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

protocol RecommendedVideoCarouselViewDelegate: AnyObject {
    func recommendedCarousel(_ view: RecommendedVideoCarouselView, didSelectItemAt index: Int)
}

struct RecommendedCarouselItem: Hashable {
    let videoThumbnailURL: URL
    let videoTitle: String?
    let videoDetail: String?
}

final class RecommendedVideoCarouselView: UIView, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching {
    weak var delegate: RecommendedVideoCarouselViewDelegate?
    var onPageChanged: ((Int) -> Void)?
    private var baseItems: [RecommendedCarouselItem] = []
    private var baseCount: Int { baseItems.count }
    private let repeatFactor: Int = 3
    private enum Section { case main }
    private struct VirtualItem: Hashable {
        let id = UUID()
        let realIndex: Int
    }
    
    private var virtualItems: [VirtualItem] = []
    private var totalItems: Int { virtualItems.count }
    
    private var currentVirtualIndex: Int = 0
    private var currentRealIndex: Int {
        guard baseCount > 0, totalItems > 0 else { return 0 }
        return virtualItems[currentVirtualIndex].realIndex
    }
    private var middleBlockStart: Int {
        return baseCount
    }
    
    private var autoTimer: Timer?
    private var resumeWorkItem: DispatchWorkItem?
    private var autoInterval: TimeInterval = 3.0
    
    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.scrollDirection = .horizontal
        l.minimumLineSpacing = 0
        l.minimumInteritemSpacing = 0
        return l
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.decelerationRate = .normal
        cv.register(RecommendedVideoCarouselCell.self,
                    forCellWithReuseIdentifier: RecommendedVideoCarouselCell.reuseID)
        cv.delegate = self
        cv.prefetchDataSource = self
        return cv
    }()
    
    // Diffable Data Source
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, VirtualItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, VirtualItem>
    private var dataSource: DataSource!

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        
        collectionView.pinToSuperview()
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, vItem in
            guard
                let self = self,
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecommendedVideoCarouselCell.reuseID,
                    for: indexPath
                ) as? RecommendedVideoCarouselCell
            else {
                return UICollectionViewCell()
            }
            
            if self.baseCount > 0 {
                let item = self.baseItems[vItem.realIndex]
                cell.configure(with: item.videoThumbnailURL, title: item.videoTitle, detail: item.videoDetail)
            }
            return cell
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        autoTimer?.invalidate()
        resumeWorkItem?.cancel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let itemSize = CGSize(width: bounds.width, height: bounds.height)
        if layout.itemSize != itemSize {
            layout.itemSize = itemSize
            layout.invalidateLayout()
            syncScroll(toVirtual: currentVirtualIndex, animated: false)
        }
    }

    func setItems(_ items: [RecommendedCarouselItem]) {
        self.baseItems = items
        rebuildVirtualItems()
        applySnapshot(animating: false)
        guard baseCount > 0 else { return }
        collectionView.layoutIfNeeded()
        currentVirtualIndex = min(middleBlockStart, max(0, totalItems - 1))
        syncScroll(toVirtual: currentVirtualIndex, animated: false)
        onPageChanged?(currentRealIndex)
        prefetchAround(virtualIndex: currentVirtualIndex)
    }
    
    func scroll(to index: Int, animated: Bool) {
        guard baseCount > 0, (0..<baseCount).contains(index) else { return }
        let targetVirtual = (baseCount <= 1) ? index : (middleBlockStart + index)
        currentVirtualIndex = targetVirtual
        syncScroll(toVirtual: targetVirtual, animated: animated)
        if !animated { onPageChanged?(currentRealIndex) }
        prefetchAround(virtualIndex: currentVirtualIndex)
    }
    
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
        guard !collectionView.isDragging, !collectionView.isDecelerating else { return }
        guard baseCount > 1 else { return }
        let nextVirtual = currentVirtualIndex + 1
        currentVirtualIndex = min(nextVirtual, max(0, totalItems - 1))
        syncScroll(toVirtual: nextVirtual, animated: true)
        prefetchAround(virtualIndex: nextVirtual)
    }
    
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
    
    private func pageWidth() -> CGFloat { max(1, collectionView.bounds.width) }
    private func currentPage() -> Int {
        let x = collectionView.contentOffset.x
        let p = Int(round(x / pageWidth()))
        return max(0, min(p, max(0, totalItems - 1)))
    }
    
    private func syncScroll(toVirtual vIndex: Int, animated: Bool) {
        guard totalItems > 0 else { return }
        collectionView.layoutIfNeeded()
        let clamped = max(0, min(vIndex, totalItems - 1))
        let indexPath = IndexPath(item: clamped, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        if !animated {
            recenterIfNeeded(aroundVirtual: clamped)
        }
    }
    
    private func recenterIfNeeded(aroundVirtual vIndex: Int? = nil) {
        guard baseCount > 0, totalItems >= baseCount * 3 else { return }
        let v = vIndex ?? currentPage()
        let real = virtualItems[v].realIndex
        if v < baseCount || v >= baseCount * 2 {
            let middle = middleBlockStart + real
            currentVirtualIndex = middle
            let ip = IndexPath(item: middle, section: 0)
            collectionView.scrollToItem(at: ip, at: .centeredHorizontally, animated: false)
        }
    }
    
    private func prefetchAround(virtualIndex: Int) {
        guard baseCount > 0, totalItems > 0 else { return }
        let candidates = [
            virtualIndex - 2, virtualIndex - 1,
            virtualIndex,     virtualIndex + 1, virtualIndex + 2
        ].filter { $0 >= 0 && $0 < totalItems }
        
        let urls: [URL] = candidates.compactMap { idx in
            let real = virtualItems[idx].realIndex
            return baseItems[real].videoThumbnailURL
        }
        RecommendedVideoImageLoader.shared.prefetch(urls: urls)
    }
    
    private func rebuildVirtualItems() {
        virtualItems.removeAll()
        guard baseCount > 0 else { return }
        if baseCount == 1 {
            virtualItems = [VirtualItem(realIndex: 0)]
            return
        }
        var tmp: [VirtualItem] = []
        for _ in 0..<repeatFactor {
            for real in 0..<baseCount {
                tmp.append(VirtualItem(realIndex: real))
            }
        }
        virtualItems = tmp
    }
    
    private func applySnapshot(animating: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(virtualItems, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: animating)
    }
}

extension RecommendedVideoCarouselView {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard baseCount > 0, !indexPaths.isEmpty else { return }
        let urls: [URL] = indexPaths.compactMap { indexPath in
            guard indexPath.item < totalItems else { return nil }
            let real = virtualItems[indexPath.item].realIndex
            return baseItems[real].videoThumbnailURL
        }
        RecommendedVideoImageLoader.shared.prefetch(urls: urls)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    }
}

extension RecommendedVideoCarouselView {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
        resumeWorkItem?.cancel()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let v = currentPage()
        currentVirtualIndex = v
        recenterIfNeeded(aroundVirtual: v)
        onPageChanged?(currentRealIndex)
        scheduleAutoResume(after: 0.5)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let v = currentPage()
            currentVirtualIndex = v
            recenterIfNeeded(aroundVirtual: v)
            onPageChanged?(currentRealIndex)
            scheduleAutoResume(after: 0.5)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let v = currentPage()
        currentVirtualIndex = v
        recenterIfNeeded(aroundVirtual: v)
        onPageChanged?(currentRealIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard baseCount > 0, indexPath.item < totalItems else { return }
        let real = virtualItems[indexPath.item].realIndex
        delegate?.recommendedCarousel(self, didSelectItemAt: real)
    }
}
