//
//  FirestoreVideoListMapper.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation

// MARK: Jay - 공용 Mapper (DTO → 각 도메인 모델)
enum FirestoreVideoListMapper {
    
    // MARK: Jay - 문자열 → VideoCategory
    private static func stringToCategory(_ str: String) -> VideoCategory {
        VideoCategory(rawValue: str) ?? .unknown
    }

    // MARK: Jay - DTO → RecommendedVideoModel
    static func toRecommendedVideoModel(_ dto: FirestoreVideoListDTO) -> RecommendedVideoModel? {
        guard let uuid = UUID(uuidString: dto.id) else { return nil }
        guard let thumb = URL(string: dto.thumbnailURL) else { return nil }

        return RecommendedVideoModel(
            id: uuid,
            title: dto.title,
            detail: dto.description,
            categories: dto.categories,
            thumbnailURL: thumb
        )
    }

    
//    // MARK: Jay - DTO → VideoListItem
//    static func toVideoListItem(_ dto: FirestoreVideoListDTO) -> VideoListItem? {
//        guard let uuid = UUID(uuidString: dto.id) else { return nil }
//        let thumb = URL(string: dto.thumbnailURL)
//
//        let categories = dto.categories.map { stringToCategory($0) }
//
//        return VideoListItem(
//            id: uuid,
//            thumbnailURL: thumb,
//            title: dto.title,
//            descriptionText: dto.description,
//            isLiked: dto.isLiked ?? false,
//            categories: categories
//        )
//    }

    // MARK: Jay - 정렬 유틸 (예: lastWatchedAt 우선 → viewCount)
    static func sortByRecentThenViewCount(_ lhs: FirestoreVideoListDTO, _ rhs: FirestoreVideoListDTO) -> Bool {
        let l = lhs.lastWatchedAt?.dateValue() ?? .distantPast
        let r = rhs.lastWatchedAt?.dateValue() ?? .distantPast
        if l != r { return l > r }
        return lhs.viewCount > rhs.viewCount
    }

    // MARK: Jay - 순수 viewCount 기준 정렬
    static func sortByViewCount(_ lhs: FirestoreVideoListDTO, _ rhs: FirestoreVideoListDTO) -> Bool {
        lhs.viewCount > rhs.viewCount
    }
}
