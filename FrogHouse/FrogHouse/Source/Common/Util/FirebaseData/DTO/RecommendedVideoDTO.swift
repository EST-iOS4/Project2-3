//
//  RecommendedVideoDTO.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//
import Foundation
import FirebaseFirestore

// MARK: Jay - Firestore DTO (문서 내부 id = UUID 문자열 사용)
struct RecommendedVideoDTO: Codable, FirestoreDomainMappable {
    // MARK: Jay - 문서 내부 UUID 문자열 id (필수)
    let id: String
    // MARK: Jay - 비디오 제목
    let title: String
    // MARK: Jay - 비디오 설명
    let description: String
    // MARK: Jay - 카테고리 목록
    let categories: [String]
    // MARK: Jay - mp4 영상 URL (문자열)
    let mp4URL: String
    // MARK: Jay - 썸네일 이미지 URL (문자열)
    let thumbnailURL: String
    // MARK: Jay - 조회수
    let viewCount: Int
    // MARK: Jay - 생성일(옵션)
    @ServerTimestamp var createdAt: Timestamp?
    // MARK: Jay - 좋아요 여부(옵션)
    let isLiked: Bool?

    // MARK: Jay - DTO → Domain 변환
    func toDomain() -> RecommendedVideoModel? {
        // MARK: Jay - id → UUID 파싱
        guard let uuid = UUID(uuidString: id) else {
            print("🔥 Jay - toDomain fail: invalid id '\(id)'")
            return nil
        }
        // MARK: Jay - thumbnailURL → URL
        guard let thumbnailURL = URL(string: thumbnailURL) else {
            print("🔥 Jay - toDomain fail: invalid thumbnailURL '\(thumbnailURL)' (id: \(id))")
            return nil
        }
        // MARK: Jay - 모델 생성
        return RecommendedVideoModel(
            id: uuid,
            title: title,
            detail: description,
            tags: categories,
            thumbnailURL: thumbnailURL
        )
    }
}
