//
//  RecommendedViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

// MARK: Jay - Repository 임시 프로토콜 (API 받아서 교체예정)
public protocol RecommendedVideoTempRepository {
    func fetchRecommended() async throws -> [RecommendedVideoModel]
}

// MARK: Jay - ViewModel
final class RecommendedVideoViewModel {
    
    // MARK: Jay - Outputs (UI 업데이트 신호)
    public var onCurrentItemChanged: ((RecommendedVideoModel, Int, Int) -> Void)?
    public var onListUpdated: (([RecommendedVideoModel]) -> Void)?
    public var onLoadingChanged: ((Bool) -> Void)?
    public var onError: ((String) -> Void)?
    
    // MARK: Jay - Data
    private(set) var items: [RecommendedVideoModel] = []
    private(set) var currentIndex: Int = 0 {
        didSet { notifyChange() }
    }
    
    // MARK: Jay - Repository (API 주입되면 사용, 없으면 Mock 모드)
    private let repository: RecommendedVideoTempRepository?
    // MARK: Jay - 현재 임의로 30개 제한 (변경될수 있음)
    private let maxCount = 30
    
    // MARK: Jay - Init (Mock / 수동 주입용)
    public init(items: [RecommendedVideoModel]) {
        // MARK: Jay - 현재 임의로 30개 제한 (변경될수 있음)
        self.items = Array(items.prefix(maxCount))
        self.repository = nil
    }
    
    // MARK: Jay - Init (API 주입용)
    public init(repository: RecommendedVideoTempRepository) {
        self.repository = repository
    }
    
    // MARK: Jay - Load (Mock / API 모두 여기로 통일)
    public func load() {
        guard let repository else {
            // Mock 모드: 현재 보유 items 방출
            onListUpdated?(items)
            if items.indices.contains(currentIndex) {
                onCurrentItemChanged?(items[currentIndex], currentIndex, items.count)
            }
            return
        }
        Task {
            await MainActor.run { onLoadingChanged?(true) }
            do {
                let fetched = try await repository.fetchRecommended()
                await MainActor.run {
                    self.items = Array(fetched.prefix(self.maxCount)) //30개 제한
                    self.currentIndex = min(self.currentIndex, max(0, self.items.count - 1))
                    self.onListUpdated?(self.items)
                    self.onLoadingChanged?(false)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingChanged?(false)
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Jay - Index 제어
    public func setCurrentIndex(_ index: Int) {
        guard items.indices.contains(index), currentIndex != index else { return }
        currentIndex = index
    }
    public func item(at index: Int) -> RecommendedVideoModel? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }
    
    // MARK: Jay - 변화감지
    private func notifyChange() {
        guard items.indices.contains(currentIndex) else { return }
        onCurrentItemChanged?(items[currentIndex], currentIndex, items.count)
    }
}

// MARK: Jay - 임시 mockData
extension RecommendedVideoViewModel {
    static func makeMockData() -> RecommendedVideoViewModel {
        let samples: [RecommendedVideoModel] = [
            .init(
                title: "푸른 바다",
                detail: "이야 물놀이~!! 여름을 즐겨봐요. 시원한 바다와 트로피컬음악",
                tags: ["추천", "여행", "힐링"],
                thumbnailURL: URL(string: "https://i.pinimg.com/736x/2c/be/b0/2cbeb0fd0c44f1d3ea546c08d9359b7f.jpg")!
            ),
            .init(
                title: "도시 야경",
                detail: "반짝이는 야경과 함께하는 씨티팝",
                tags: ["야경", "포토스팟"],
                thumbnailURL: URL(string: "https://i.pinimg.com/1200x/89/6d/b8/896db8e11ee0f034d042c3a369f17e50.jpg")!
            ),
            .init(
                title: "힐링 숲길",
                detail: "초록빛 숲길을 따라 천천히 산책하며 힐링해요.",
                tags: ["자연", "산책", "휴식"],
                thumbnailURL: URL(string: "https://i.pinimg.com/1200x/80/ba/16/80ba161f36421a677ccdf8cb99412a4d.jpg")!
            ),
            .init(
                title: "따뜻한 카페",
                detail: "커피냄새와 함께 보내는 오후, 카페에서 공부하면서 갓생살기.",
                tags: ["카페", "디저트", "공부"],
                thumbnailURL: URL(string: "https://i.pinimg.com/1200x/df/84/13/df8413f94bff4999471c31ed9bad363d.jpg")!
            ),
            .init(
                title: "퇴근 후 드라이브",
                detail: "오늘 하루도 무사히 보냈다! 퇴근 후 즐기는 드라이브.",
                tags: ["풍경", "드라이브"],
                thumbnailURL: URL(string: "https://i.pinimg.com/736x/22/b5/ce/22b5ce8a1ea8036f3b434d8158decd04.jpg")!
            ),
            .init(
                title: "부장님과 주말 등산",
                detail: "왜 등산을 주말에... 는 너무 좋습니다! 와! 자연최고!! 부장님 짱!!",
                tags: ["등산", "아웃도어", "직장", "태그1", "태그2", "태그3", "태그4", "태그5", "태그6"],
                thumbnailURL: URL(string: "https://i.pinimg.com/1200x/13/da/39/13da3948b4297ea7407d1d39c6e8d57b.jpg")!
            )
        ]
        return RecommendedVideoViewModel(items: samples)
    }
}
