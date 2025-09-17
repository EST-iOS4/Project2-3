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
    
    func selectCategory(at index: Int) async throws {
        selectedCategoryIndex = index
        try await fetchVideoList()
    }
    
    func fetchVideoList() async throws {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }
        let dtos = try await FirestoreVideoListStore.shared.loadFirestoreData(type: .createdAtDesc)
        let all: [VideoListItem] = dtos.compactMap {
            FirestoreVideoListMapper.toVideoListItem($0)
        }
        self.videoList = self.filtered(all)
    }

    func toggleLike(id: UUID, isLiked: Bool) async throws {
        if let idx = videoList.firstIndex(where: { $0.id == id }) {
            var item = videoList[idx]
            item.isLiked = isLiked
            videoList[idx] = item
        }
        try await FirestoreCRUDHelper.updateIsLiked(id: id, isLiked: isLiked)
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
