//
//  FirestoreVideoListDTO.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation
import FirebaseFirestore

// MARK: Jay - Firestore 공용 DTO (VideoList 컬렉션의 문서 스키마)
struct FirestoreVideoListDTO: Codable {
    // MARK: Jay - 문서 내부 UUID 문자열 id (필수)
    let id: String
    // MARK: Jay - 제목
    let title: String
    // MARK: Jay - 설명
    let description: String
    // MARK: Jay - 카테고리 문자열 배열
    let categories: [String]
    // MARK: Jay - mp4 영상 URL (문자열)
    let mp4URL: String
    // MARK: Jay - 썸네일 이미지 URL (문자열)
    let thumbnailURL: String
    // MARK: Jay - 조회수
    let viewCount: Int
    // MARK: Jay - 생성일
    @ServerTimestamp var createdAt: Timestamp?
    // MARK: Jay - 마지막 시청일
    @ServerTimestamp var lastWatchedAt: Timestamp?
    // MARK: Jay - 좋아요 여부(옵션)
    let isLiked: Bool?
}
