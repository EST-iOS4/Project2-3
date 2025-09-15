//
//  MyVideoViewModel.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import Combine
import Foundation

final class MyVideoViewModel {
    @Published private(set) var historyVideoModel: [Video] = []
    @Published private(set) var likedVideoModel: [Video] = []
    
    func fetchMyVideoModel() throws {
        let historyRequest = Video.fetchRequest()
        historyRequest.predicate = NSPredicate(format: "statistics.viewCount > 0")
        historyRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        historyRequest.fetchLimit = 5
        
        let historyVideos = try PersistenceManager.shared.fetch(request: historyRequest)
        historyVideoModel = historyVideos
        
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
