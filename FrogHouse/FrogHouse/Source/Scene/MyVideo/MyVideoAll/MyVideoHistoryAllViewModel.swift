//
//  MyVideoHistoryAllViewModel.swift
//  FrogHouse
//
//  Created by 서정원 on 9/14/25.
//

import Combine
import Foundation

final class MyVideoHistoryAllViewModel {
    @Published private(set) var videoList: [Video] = []
    
    func fetchVideoList() throws {
        let request = Video.fetchRequest()
        request.predicate = NSPredicate(format: "statistics.viewCount > 0")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        videoList = try PersistenceManager.shared.fetch(request: request)
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
