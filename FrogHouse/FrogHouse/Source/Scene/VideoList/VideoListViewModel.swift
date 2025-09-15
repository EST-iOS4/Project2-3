//
//  VideoListViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

final class VideoListViewModel {
    struct VideoListItem: Hashable {
        let id: UUID
        let thumbnailURL: URL?
        let title: String
        let descriptionText: String
        var isLiked: Bool
        let categories: [VideoCategory]
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(isLiked)
        }
    }
    
    private var isLoading = false
    @Published private(set) var videoList: [VideoListItem] = []
    @Published private(set) var categories: [VideoCategory] = VideoCategory.allCases
    @Published private(set) var selectedCategoryIndex: Int = 0
    
    func selectCategory(at index: Int) throws {
        selectedCategoryIndex = index
        try fetchVideoList()
    }
    
    func fetchVideoList() throws {
        let request = Video.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let allVideoList: [VideoListItem] = try PersistenceManager.shared.fetch(request: request).map { .init(id: $0.id, thumbnailURL: $0.thumbnailURL, title: $0.title, descriptionText: $0.descriptionText, isLiked: $0.isLiked, categories: $0.videoCategories) }
        let selectedCategory = categories[selectedCategoryIndex]
        
        if selectedCategory == .all {
            videoList = allVideoList
        } else {
            videoList = allVideoList.filter { $0.categories.contains(selectedCategory) }
        }
    }
    
    func toggleLike(at video: VideoListItem) throws {
        guard let selectedIndex = videoList.firstIndex(where: { $0.id == video.id }) else { return }
        let updatedVideoState = !videoList[selectedIndex].isLiked
        
        try PersistenceManager.shared.updateVideo(videoID: video.id) { video in
            video.isLiked = updatedVideoState
        }
        videoList[selectedIndex].isLiked = updatedVideoState
    }
}
