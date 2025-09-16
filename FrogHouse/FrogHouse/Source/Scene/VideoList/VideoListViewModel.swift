//
//  VideoListViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation
import Combine
import FirebaseFirestore

final class VideoListViewModel {
    
    // MARK: Jay - 상태
    private var isLoading = false
    @Published private(set) var videoList: [VideoListItem] = []
    @Published private(set) var categories: [VideoCategory] = VideoCategory.allCases
    @Published private(set) var selectedCategoryIndex: Int = 0
    
    func selectCategory(at index: Int) {
        selectedCategoryIndex = index
        applyFilter(with: videoList)
    }
    
    func fetchVideoList() async throws {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }
        
        let dtos = try await FirestoreVideoListStore.shared.loadFirestoreData()
        let sorted = FirestoreVideoListMapper.sortedDTOs(
            dtos,
            sortby: .createdAtDesc
        )
        let all: [VideoListItem] = sorted.compactMap {
            FirestoreVideoListMapper.toVideoListItem($0)
        }
        self.videoList = self.filtered(all)
    }

    func toggleLike(id: UUID, isLiked: Bool) {
        if let idx = videoList.firstIndex(where: { $0.id == id }) {
            var item = videoList[idx]
            item.isLiked = isLiked
            videoList[idx] = item
        }
        Task {
            do {
                try await FirestoreCRUDHelper.updateIsLiked(id: id, isLiked: isLiked)
            } catch {
                print("❌ 좋아요 업데이트 실패:", error)
            }
        }
    }
    
    private func filtered(_ all: [VideoListItem]) -> [VideoListItem] {
        let selected = categories[selectedCategoryIndex]
        if selected == .all { return all }
        return all.filter { $0.categories.contains(selected) }
    }
    
    private func applyFilter(with current: [VideoListItem]) {
        let selected = categories[selectedCategoryIndex]
        if selected == .all {
            videoList = current
        } else {
            videoList = current.filter { $0.categories.contains(selected) }
        }
    }
}
