//
//  MyVideoHistoryAllViewModel.swift
//  FrogHouse
//
//  Created by 서정원 on 9/14/25.
//

import Combine
import Foundation

final class MyVideoHistoryAllViewModel {
    @Published private(set) var videoList: [VideoListItem] = []
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
