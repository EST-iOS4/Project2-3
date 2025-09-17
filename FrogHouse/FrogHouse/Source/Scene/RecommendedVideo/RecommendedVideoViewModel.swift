//
//  RecommendedViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

final class RecommendedVideoViewModel {
    var onCurrentItemChanged: ((RecommendedVideoItem, Int, Int) -> Void)?
    var onListUpdated: (([RecommendedVideoItem]) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?
    private(set) var items: [RecommendedVideoItem] = []
    private(set) var currentIndex: Int = 0 { didSet { notifyChange() } }
    private let maxCount = 30
    private let store: FirestoreVideoListStore
    init(store: FirestoreVideoListStore = .shared) {
        self.store = store
    }
    func load() {
        Task {
            await MainActor.run { onLoadingChanged?(true) }
            do {
                let dtos = try await store.getOrFetch(type: .viewCountDesc)
                let all: [RecommendedVideoItem] = dtos.compactMap { FirestoreVideoListMapper.toRecommendedVideoItem($0) }
                
                await MainActor.run {
                    self.items = all
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

    func setCurrentIndex(_ index: Int) {
        guard items.indices.contains(index), currentIndex != index else { return }
        currentIndex = index
    }
    
    func item(at index: Int) -> RecommendedVideoItem? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }
    
    private func notifyChange() {
        guard items.indices.contains(currentIndex) else { return }
        onCurrentItemChanged?(items[currentIndex], currentIndex, items.count)
    }
}
