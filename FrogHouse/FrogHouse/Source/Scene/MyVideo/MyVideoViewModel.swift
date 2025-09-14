//
//  MyVideoViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Combine
import Foundation

final class MyVideoViewModel {
    struct HistoryItem: Hashable {
        let id = UUID()
        let title: String
        let thumbnailURL: URL?
    }
    
    @Published private(set) var historyVideoModel: [HistoryItem] = []
    @Published private(set) var likedVideoModel: [Video] = []
    
    func fetchMyVideoModel() throws {
        historyVideoModel = [
            HistoryItem(
                title: "오늘의 하이라이트: SwiftUI 기초 튜토리얼",
                thumbnailURL: URL(string: "https://picsum.photos/id/1011/200/120")
            ),
            HistoryItem(
                title: "iOS Combine 실습 예제",
                thumbnailURL: URL(string: "https://picsum.photos/id/1012/200/120")
            ),
            HistoryItem(
                title: "MVVM 패턴으로 앱 구조 잡기",
                thumbnailURL: URL(string: "https://picsum.photos/id/1013/200/120")
            ),
            HistoryItem(
                title: "UICollectionView Compositional Layout 배우기",
                thumbnailURL: URL(string: "https://picsum.photos/id/1014/200/120")
            ),
            HistoryItem(
                title: "AVPlayer로 비디오 스트리밍 테스트",
                thumbnailURL: URL(string: "https://picsum.photos/id/1015/200/120")
            ),
            HistoryItem(
                title: "Swift Enum과 DiffableDataSource 활용",
                thumbnailURL: URL(string: "https://picsum.photos/id/1016/200/120")
            ),
            HistoryItem(
                title: "앱 성능 최적화 전략",
                thumbnailURL: URL(string: "https://picsum.photos/id/1017/200/120")
            ),
            HistoryItem(
                title: "실전 iOS 프로젝트 구조 예시",
                thumbnailURL: URL(string: "https://picsum.photos/id/1018/200/120")
            ),
        ]
        
        let request = Video.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        request.predicate = NSPredicate(format: "isLiked == %@", NSNumber(value: true))
        
        let likedVideos = try PersistenceManager.shared.fetch(request: request)
        likedVideoModel = likedVideos
        
    }
    
    func cancelLike(at video: Video) throws {
        guard let selectedIndex = likedVideoModel.firstIndex(where: { $0.id == video.id }) else { return }
        
        try PersistenceManager.shared.updateVideo(videoID: video.id) { video in
            video.isLiked = false
        }
        
        likedVideoModel[selectedIndex].isLiked = false
    }
}
