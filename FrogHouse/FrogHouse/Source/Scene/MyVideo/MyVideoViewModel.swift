//
//  MyVideoViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Combine
import Foundation

final class MyVideoViewModel {
    struct HistoryVideoItem: Hashable {
        let id: UUID
        let thumbnailURL: URL?
        let title: String
    }
    
    struct LikedVideoItem: Hashable {
        let id: UUID
        let thumbnailURL: URL?
        let title: String
        let description: String
        let isLiked: Bool
    }
    
    @Published private(set) var historyVideoModel: [HistoryVideoItem] = []
    @Published private(set) var likedVideoModel: [LikedVideoItem] = []
    
    func fetchMyVideoViewModel() {
        Task {
            let dtos = try await FirestoreVideoListStore.shared.getOrFetch()
            
            // 시청 기록
            let history: [MyVideoViewModel.HistoryVideoItem] = dtos
                .filter { $0.lastWatchedAt != nil } // 시청 기록이 있는 영상만
                .sorted { $0.lastWatchedAt!.dateValue() > $1.lastWatchedAt!.dateValue() } // 최신순으로 정렬
                .compactMap { FirestoreVideoListMapper.toHistoryListItem($0) }
            
            // 좋아요 누른 영상
            let liked: [MyVideoViewModel.LikedVideoItem] = dtos
                .filter { $0.isLiked == true } // 좋아요 누른 영상만
                .compactMap { FirestoreVideoListMapper.toLikedListItem($0) }

            await MainActor.run {
                self.historyVideoModel = Array(history.prefix(5))
                self.likedVideoModel = liked
            }
        }
    }
    
    func cancelLike(at item: LikedVideoItem) async throws {
        try await FirestoreVideoListStore.shared.updateLikeStatus(for: item.id.uuidString, isLiked: false)
        
        await MainActor.run {
            likedVideoModel.removeAll { $0.id == item.id }
        }
    }
}
