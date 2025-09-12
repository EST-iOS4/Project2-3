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

    private var histories: [HistoryItem] = []
    private var recommendedVideos: [VideoListViewModel.Item] = []
    
    //TODO: 서정원 - String -> Image 타입으로 변경하는 메서드가 필요함
    let demoHistories = [
        HistoryItem(title: "오늘의 하이라이트1오늘의 하이라이트1오늘의 하이라이트1오늘의 하이라이트1오늘의 하이라이트1오늘의 하이라이트1오늘의 하이라이트1오늘의 하이라이트1오늘의 하이라이트1", thumbnailURL: nil),
        HistoryItem(title: "오늘의 하이라이트2", thumbnailURL: nil),
        HistoryItem(title: "오늘의 하이라이트3", thumbnailURL: nil),
        HistoryItem(title: "오늘의 하이라이트4", thumbnailURL: nil),
        HistoryItem(title: "오늘의 하이라이트5", thumbnailURL: nil),
        HistoryItem(title: "오늘의 하이라이트6", thumbnailURL: nil),
        HistoryItem(title: "오늘의 하이라이트7", thumbnailURL: nil),
        HistoryItem(title: "오늘의 하이라이트8", thumbnailURL: nil),
    ]
    
    let demoRecommendedVideos = [
        VideoListViewModel.Item(title: "asd1", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd2", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd3", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd4", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd5", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: []),
        VideoListViewModel.Item(title: "asd6", description: "asd", thumbnailImageURL: nil, isLiked: false, categories: [])
    ]
}
