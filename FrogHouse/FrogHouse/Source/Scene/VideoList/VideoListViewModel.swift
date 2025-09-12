//
//  VideoListViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

final class VideoListViewModel {
    private var isLoading = false
    @Published private(set) var videoList: [Video] = []
    @Published private(set) var categories: [VideoCategory] = VideoCategory.allCases
    @Published private(set) var selectedCategoryIndex: Int = 0
    
    func selectCategory(at index: Int) throws {
        selectedCategoryIndex = index
        try fetchVideoList()
    }
    
    func fetchVideoList() throws {
        let request = Video.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let allVideoList: [Video] = try PersistenceManager.shared.fetch(request: request)
        let selectedCategory = categories[selectedCategoryIndex]
        
        if selectedCategory == .all {
            videoList = allVideoList
        } else {
            videoList = allVideoList.filter { $0.videoCategories.contains(selectedCategory) }
        }
    }
    
    func toggleLike(at video: Video) throws {
        guard let selectedIndex = videoList.firstIndex(where: { $0.id == video.id }) else { return }
        let updatedVideoState = !videoList[selectedIndex].isLiked
        
        try PersistenceManager.shared.updateVideo(videoID: video.id) { video in
            video.isLiked = updatedVideoState
        }
        videoList[selectedIndex].isLiked = updatedVideoState
    }
}
