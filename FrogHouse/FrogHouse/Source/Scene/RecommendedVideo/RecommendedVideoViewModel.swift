//
//  RecommendedViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

// MARK: Jay - 추천 비디오 VM (BaseViewController와 호환)
final class RecommendedVideoViewModel {

    // MARK: Jay - Outputs (UI 업데이트 신호)
    var onCurrentItemChanged: ((RecommendedVideoModel, Int, Int) -> Void)?
    var onListUpdated: (([RecommendedVideoModel]) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: Jay - Data
    private(set) var items: [RecommendedVideoModel] = []
    private(set) var currentIndex: Int = 0 {
        didSet { notifyChange() }
    }

    // MARK: Jay - 최대 개수
    private let maxCount = 30

    // MARK: Jay - 리포지토리 (도메인 특화 프로토콜)
    private let repository: any RecommendedVideoRepository

    // MARK: Jay - 기본 init (TabBar에서 그대로 사용 가능)
    init() {
        // MARK: Jay - 기본 구현체를 Firestore로
        self.repository = FirestoreRecommendedVideoRepository()
    }

    // MARK: Jay - 주입 init (테스트/대체 소스용)
    init(repository: any RecommendedVideoRepository) {
        self.repository = repository
    }

    // MARK: Jay - 로드
    func load() {
        Task {
            // MARK: Jay - 로딩 on
            await MainActor.run { onLoadingChanged?(true) }
            do {
                // MARK: Jay - 데이터 로드
                let fetched = try await repository.fetchTop(limit: maxCount)
                // MARK: Jay - UI 업데이트
                await MainActor.run {
                    self.items = fetched
                    self.currentIndex = min(self.currentIndex, max(0, self.items.count - 1))
                    self.onListUpdated?(self.items)
                    self.onLoadingChanged?(false)

                    if self.items.indices.contains(self.currentIndex) {
                        self.onCurrentItemChanged?(self.items[self.currentIndex], self.currentIndex, self.items.count)
                    }
                }
            } catch {
                // MARK: Jay - 에러 전달
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
