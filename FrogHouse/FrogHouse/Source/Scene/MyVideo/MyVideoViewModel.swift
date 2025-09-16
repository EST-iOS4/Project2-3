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
    
    func fetchMyVideoViewModel() async throws {
        let dtos = try await FirestoreVideoListStore.shared.loadFirestoreData(type: .viewCountDesc)
        
        let history: [MyVideoViewModel.HistoryVideoItem] = dtos
            .filter { $0.lastWatchedAt != nil }
            .compactMap { FirestoreVideoListMapper.toHistoryListItem(dto: $0) }
        
        let liked: [MyVideoViewModel.LikedVideoItem] = dtos
            .filter { $0.isLiked == true } // 좋아요 누른 영상만
            .compactMap { FirestoreVideoListMapper.toLikedListItem(dto: $0) }

        self.historyVideoModel = Array(history.prefix(5))
        self.likedVideoModel = liked
    }
    
    func cancelLike(at item: LikedVideoItem) async throws {
        try await FirestoreCRUDHelper.updateIsLiked(id: item.id, isLiked: false)
        
        await MainActor.run {
            likedVideoModel.removeAll { $0.id == item.id }
        }
    }
}
