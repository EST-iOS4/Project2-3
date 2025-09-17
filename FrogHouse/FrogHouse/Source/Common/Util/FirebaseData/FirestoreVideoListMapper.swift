//
//  FirestoreVideoListMapper.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation

enum FirestoreVideoListMapper {
    
    private static func stringToCategory(_ str: String) -> VideoCategory {
        VideoCategory(rawValue: str) ?? .unknown
    }
    
    static func toRecommendedVideoItem(_ dto: FirestoreVideoListDTO) -> RecommendedVideoItem? {
        guard let uuid = UUID(uuidString: dto.id) else { return nil }
        guard let thumb = URL(string: dto.thumbnailURL) else { return nil }
        let categories = dto.categories.map { stringToCategory($0) }
        return RecommendedVideoItem(
            id: uuid,
            title: dto.title,
            detail: dto.description,
            categories: categories,
            thumbnailURL: thumb
        )
    }
    
    static func toVideoListItem(_ dto: FirestoreVideoListDTO) -> VideoListItem? {
        guard let uuid = UUID(uuidString: dto.id) else { return nil }
        let thumb = URL(string: dto.thumbnailURL)
        let categories = dto.categories.map { stringToCategory($0) }
        return VideoListItem(
            id: uuid,
            thumbnailURL: thumb,
            title: dto.title,
            descriptionText: dto.description,
            isLiked: dto.isLiked ?? false,
            categories: categories
        )
    }
    
    static func sortByViewCount(_ lhs: FirestoreVideoListDTO, _ rhs: FirestoreVideoListDTO) -> Bool {
        lhs.viewCount > rhs.viewCount
    }
    
    static func toHistoryListItem( dto: FirestoreVideoListDTO) -> MyVideoViewModel.HistoryVideoItem? {
        guard let uuid = UUID(uuidString: dto.id) else { return nil }
        let thumbnailURL = URL(string: dto.thumbnailURL)
        let title = dto.title
        return MyVideoViewModel.HistoryVideoItem(id: uuid,
                                                 thumbnailURL: thumbnailURL,
                                                 title: title)
    }
    
    static func toLikedListItem( dto: FirestoreVideoListDTO) -> MyVideoViewModel.LikedVideoItem? {
        guard let uuid = UUID(uuidString: dto.id) else { return nil }
        let thumbnailURL = URL(string: dto.thumbnailURL)
        let title = dto.title
        let description = dto.description
        let isLiked = dto.isLiked
        
        return MyVideoViewModel.LikedVideoItem(
            id: uuid,
            thumbnailURL: thumbnailURL,
            title: title,
            description: description,
            isLiked: isLiked ?? false
        )
    }
}

extension FirestoreVideoListMapper {
    static func toVideoDetailItem(_ dto: FirestoreVideoListDTO) -> VideoDetailViewModel.VideoDetailItem? {
        let categories: [VideoCategory] = dto.categories.map { VideoCategory(rawValue: $0) ?? .unknown }
        let createdAt = dto.createdAt?.dateValue() ?? .distantPast
        let thumb = URL(string: dto.thumbnailURL)
        return VideoDetailViewModel.VideoDetailItem(
            title: dto.title,
            descriptionText: dto.description,
            thumbnailURL: thumb,
            viewCount: dto.viewCount,
            categories: categories,
            createdAt: createdAt,
            isLiked: dto.isLiked ?? false
        )
    }
}
