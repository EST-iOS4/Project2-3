//
//  RecommendedViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation
import CoreData

// MARK: Jay - ViewModel
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
    
    // MARK: Jay - 현재 임의로 30개 제한 (변경될수 있음)
    private let maxCount = 30
    
    // MARK: Jay - Init (Core Data 전용)
    init() {}
    
    // MARK: Jay - Load (Core Data에서 조회수 기준 내림차순 로드)
    func load() {
        Task {
            await MainActor.run { onLoadingChanged?(true) }
            do {
                let fetched = try fetchRecommendedFromCoreData()
                await MainActor.run {
                    self.items = Array(fetched.prefix(self.maxCount)) //30개 제한
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
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Jay - Index 제어
    func setCurrentIndex(_ index: Int) {
        guard items.indices.contains(index), currentIndex != index else { return }
        currentIndex = index
    }
    func item(at index: Int) -> RecommendedVideoModel? {
        guard items.indices.contains(index) else { return nil }
        return items[index]
    }
    
    // MARK: Jay - 변화감지
    private func notifyChange() {
        guard items.indices.contains(currentIndex) else { return }
        onCurrentItemChanged?(items[currentIndex], currentIndex, items.count)
    }
}

// MARK: Jay - Local(Core Data) Helpers
extension RecommendedVideoViewModel {
    // MARK: Jay - Core Data에서 Statistics를 viewCount 내림차순으로 가져와 연관 Video를 모델로 매핑
    private func fetchRecommendedFromCoreData() throws -> [RecommendedVideoModel] {
        // 1) Statistics: viewCount DESC
        let request = Statistics.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "viewCount", ascending: false)]
        request.fetchLimit = 100 // 여유로 넉넉히 가져온 뒤 상위 maxCount만 사용
        let statsList: [Statistics] = try PersistenceManager.shared.fetch(request: request)
        
        // 2) 연관 Video → RecommendedVideoModel 매핑 (중복 방지)
        var seen = Set<UUID>()
        var results: [RecommendedVideoModel] = []
        results.reserveCapacity(min(maxCount, statsList.count))
        
        for stats in statsList {
            guard let video = stats.video else { continue }  // 연관 관계
            let id = video.id                                // Video.id (UUID - non-optional 가정)
            guard !seen.contains(id) else { continue }
            
            // thumbnailURL: URL?이면 nil 스킵 (필요 시 placeholder 적용 가능)
            guard let thumbnailURL = video.thumbnailURL else { continue }
            
            // VideoCategory → String 태그로 변환 (엔티티에 맞게 조정)
            let tags = video.videoCategories.map { $0.title }
            
            results.append(
                RecommendedVideoModel(
                    id: id,
                    title: video.title,
                    detail: video.descriptionText,
                    tags: tags,
                    thumbnailURL: thumbnailURL
                )
            )
            seen.insert(id)
            
            if results.count >= maxCount { break }
        }
        
        return results
    }
}
