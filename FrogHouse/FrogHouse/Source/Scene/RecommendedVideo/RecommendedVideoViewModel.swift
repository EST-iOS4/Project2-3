//
//  RecommendedViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

// MARK: Jay - 추천 비디오 VM (Store + Mapper 직접 사용, 레포지토리 없음)
final class RecommendedVideoViewModel {

    // MARK: Jay - Outputs
    var onCurrentItemChanged: ((RecommendedVideoModel, Int, Int) -> Void)?
    var onListUpdated: (([RecommendedVideoModel]) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: Jay - Data
    private(set) var items: [RecommendedVideoModel] = []
    private(set) var currentIndex: Int = 0 { didSet { notifyChange() } }

    // MARK: Jay - 제한
    private let maxCount = 30

    // MARK: Jay - Store
    private let store: FirestoreVideoListStore

    // MARK: Jay - 초기화
    init(store: FirestoreVideoListStore = .shared) {
        self.store = store
        // MARK: Jay - 필요 시 실시간 리스닝 시작 (원치 않으면 주석)
        // store.startListening(orderBy: "viewCount", descending: true)
    }

    // MARK: Jay - 로드
    func load() {
        Task {
            await MainActor.run { onLoadingChanged?(true) }
            do {
                // MARK: Jay - DTO 가져오기 (TTL 고려)
                let dtos = try await store.getOrFetch(orderBy: "viewCount", descending: true)

                // MARK: Jay - 정렬 (recent → viewCount) 원하면 바꾸기
                let sorted = dtos.sorted(by: FirestoreVideoListMapper.sortByRecentThenViewCount)

                // MARK: Jay - 매핑 후 상위 N개
                var models: [RecommendedVideoModel] = []
                models.reserveCapacity(maxCount)
                for dto in sorted {
                    if let m = FirestoreVideoListMapper.toRecommendedVideoModel(dto) {
                        models.append(m)
                        if models.count >= maxCount { break }
                    }
                }

                await MainActor.run {
                    self.items = models
                    self.currentIndex = min(self.currentIndex, max(0, self.items.count - 1))
                    self.onListUpdated?(self.items)
                    self.onLoadingChanged?(false)
                    if self.items.indices.contains(self.currentIndex) {
                        self.onCurrentItemChanged?(self.items[self.currentIndex], self.currentIndex, self.items.count)
                    }
                }
            } catch {
                await MainActor.run {
                    self.onLoadingChanged?(false)
                    self.onError?("로드 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Jay - Index 제어
    func setCurrentIndex(_ index: Int) {
        guard items.indices.contains(index), currentIndex != index else { return }
        currentIndex = index
    }

    // MARK: Jay - 아이템 접근
    func item(at index: Int) -> RecommendedVideoModel? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }

    // MARK: Jay - 변화감지 알림
    private func notifyChange() {
        guard items.indices.contains(currentIndex) else { return }
        onCurrentItemChanged?(items[currentIndex], currentIndex, items.count)
    }
}
