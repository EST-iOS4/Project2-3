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
    var onCurrentItemChanged: ((RecommendedVideoItem, Int, Int) -> Void)?
    var onListUpdated: (([RecommendedVideoItem]) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: Jay - Data
    private(set) var items: [RecommendedVideoItem] = []
    private(set) var currentIndex: Int = 0 { didSet { notifyChange() } }

    // MARK: Jay - 제한
    private let maxCount = 30

    // MARK: Jay - Store
    private let store: FirestoreVideoListStore

    // MARK: Jay - 초기화
    init(store: FirestoreVideoListStore = .shared) {
        self.store = store
        // MARK: Jay - 필요 시 실시간 리스닝 (원치 않으면 주석 처리)
        // store.startListening()
    }

    // MARK: Jay - 로드 (캐시 우선, TTL 지나면 자동 갱신)
    func load() {
        Task {
            await MainActor.run { onLoadingChanged?(true) }
            do {
                // MARK: Jay - DTO 가져오기 (캐시 유효하면 캐시, 아니면 Firestore에서 갱신)
                let dtos = try await store.getOrFetch()

                // MARK: Jay - 정렬 (lastWatchedAt 우선 → viewCount)
                let sorted = dtos.sorted(by: FirestoreVideoListMapper.sortByRecentThenViewCount)

                // MARK: Jay - 매핑 후 상위 N개만 사용
                var tmp: [RecommendedVideoItem] = []
                tmp.reserveCapacity(maxCount)
                for dto in sorted {
                    if let m = FirestoreVideoListMapper.toRecommendedVideoItem(dto) {
                        tmp.append(m)
                        if tmp.count >= maxCount { break }
                    }
                }

                // MARK: Jay - Swift 6 동시성: 불변 스냅샷으로 UI 업데이트
                let finalModels = tmp
                await MainActor.run { [finalModels] in
                    self.items = finalModels
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
    func item(at index: Int) -> RecommendedVideoItem? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }

    // MARK: Jay - 변화감지 알림
    private func notifyChange() {
        guard items.indices.contains(currentIndex) else { return }
        onCurrentItemChanged?(items[currentIndex], currentIndex, items.count)
    }
}
