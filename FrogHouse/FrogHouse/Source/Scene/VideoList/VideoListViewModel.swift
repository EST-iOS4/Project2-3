//
//  VideoListViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Foundation

final class VideoListViewModel {
    struct Item: Hashable {
        let id = UUID()
        let title: String
        let description: String
        let thumbnailImageURL: URL?
        var isLiked: Bool
        let categories: [VideoCategory]
    }
    
    private var isLoading = false
    @Published private(set) var videoList: [Item] = []
    @Published private(set) var categories: [VideoCategory] = VideoCategory.allCases
    @Published private(set) var selectedCategoryIndex: Int = 0
    
    func selectCategory(at index: Int) {
        selectedCategoryIndex = index
        fetchVideoList()
    }
    
    func fetchVideoList() {
        let allVideoList: [Item] = [
            .init(
                title: "iOS Combine Tutorial",
                description: "Learn how to use Combine framework in your iOS apps.",
                thumbnailImageURL: URL(string: "https://picsum.photos/200/300"),
                isLiked: true,
                categories: [.music]
            ),
            .init(
                title: "Swift Concurrency Basics",
                description: "Understand async/await and structured concurrency in Swift.",
                thumbnailImageURL: URL(string: "https://picsum.photos/200/301"),
                isLiked: false,
                categories: [.music]
            ),
            .init(
                title: "AVFoundation Deep Dive",
                description: "Explore video playback, editing, and exporting with AVFoundation.",
                thumbnailImageURL: URL(string: "https://picsum.photos/200/302"),
                isLiked: true,
                categories: [.sports]
            ),
            .init(
                title: "UI Design Principles",
                description: "Best practices for creating intuitive and beautiful UIs.",
                thumbnailImageURL: URL(string: "https://picsum.photos/200/303"),
                isLiked: false,
                categories: [.gaming]
            )
        ]
        
        let selectedCategory = categories[selectedCategoryIndex]
        
        if selectedCategory == .all {
            videoList = allVideoList
        } else {
            videoList = allVideoList.filter { $0.categories.contains(selectedCategory) }
        }
    }
    
    func toggleLike(at index: Int) {
        guard 0..<videoList.count ~= index else { return }
        videoList[index].isLiked.toggle()
    }
}
