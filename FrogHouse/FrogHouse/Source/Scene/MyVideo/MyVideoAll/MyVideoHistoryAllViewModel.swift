//
//  MyVideoHistoryAllViewModel.swift
//  FrogHouse
//
//  Created by 서정원 on 9/14/25.
//

import Combine
import Foundation

final class MyVideoHistoryAllViewModel {
//    struct VideoListAllItem: Hashable {
//        let id: UUID
//        let thumbnailURL: URL?
//        let title: String
//        let descriptionText: String
//        var isLiked: Bool
//        let categories: [VideoCategory]
//        let viewCount: Int
//
//        func hash(into hasher: inout Hasher) {
//            hasher.combine(id)
//            hasher.combine(isLiked)
//        }
//    }
    @Published private(set) var videoList: [VideoListItem] = []
    
//    func fetchVideoList() throws {
//        let request = Video.fetchRequest()
//        request.predicate = NSPredicate(format: "statistics.viewCount > 0")
//        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//
//        videoList = try PersistenceManager.shared.fetch(request: request)
//    }
//
//    func toggleLike(at video: Video) throws {
//        guard let selectedIndex = videoList.firstIndex(where: { $0.id == video.id }) else { return }
//        let updatedVideoState = !videoList[selectedIndex].isLiked
//
//        try PersistenceManager.shared.updateVideo(videoID: video.id) { video in
//            video.isLiked = updatedVideoState
//        }
//        videoList[selectedIndex].isLiked = updatedVideoState
//    }
    func fetchVideoList() async throws {
        let dtos = try await FirestoreVideoListStore.shared.loadFirestoreData(type: .lastWatchedAtDesc)
        let all: [VideoListItem] = dtos.filter { $0.lastWatchedAt != nil }
            .compactMap { FirestoreVideoListMapper.toVideoListItem($0) }
        self.videoList = all
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
}
