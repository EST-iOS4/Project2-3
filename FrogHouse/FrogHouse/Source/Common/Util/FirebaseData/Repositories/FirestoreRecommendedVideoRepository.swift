//
//  FirestoreRecommendedVideoRepository.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation

// MARK: Jay - 추천 비디오 리포지토리 (프로토콜 + Firestore 구현)
protocol RecommendedVideoRepository: BaseRepository where Model == RecommendedVideoModel { }


// MARK: Jay - Recommended 전용 Firestore 리포지토리 (제네릭 베이스 재사용)
final class FirestoreRecommendedVideoRepository: RecommendedVideoRepository {

    // MARK: Jay - 내부 베이스 (컬렉션/정렬 필드 지정)
    private let base = FirestoreBaseRepository<RecommendedVideoDTO>(
        collectionName: "VideoList",
        orderField: "viewCount",
        descending: true
    )

    // MARK: Jay - 조회수 기준 상위 N개 조회
    func fetchTop(limit: Int) async throws -> [RecommendedVideoModel] {
        try await base.fetchTop(limit: limit)
    }
}

