//
//  RecommendedVideoModel.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//
//import Foundation
//
//struct RecommendedVideoModel: Identifiable, Equatable, Hashable {
//    let id: UUID
//    let title: String
//    let detail: String
//    let tags: [String]
//    let thumbnailURL: URL
//
//    init(id: UUID, title: String, detail: String, tags: [String], thumbnailURL: URL) {
//        self.id = id
//        self.title = title
//        self.detail = detail
//        self.tags = tags
//        self.thumbnailURL = thumbnailURL
//    }
//
//    // Equatable: id만 비교
//    static func == (lhs: RecommendedVideoModel, rhs: RecommendedVideoModel) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    // Hashable: id만 해시
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
import Foundation

// MARK: Jay - 추천 섹션에서 사용할 경량 모델 (Hashable)
struct RecommendedVideoItem: Hashable {
    // MARK: Jay - 고유 식별자
    let id: UUID
    // MARK: Jay - 제목
    let title: String
    // MARK: Jay - 상세 설명
    let detail: String
    // MARK: Jay - 태그(카테고리 문자열)
    let categories: [VideoCategory]
    // MARK: Jay - 썸네일 URL
    let thumbnailURL: URL

    // MARK: Jay - 해시 (필요시 필드 추가 가능)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        // MARK: Jay - 필요 시 추가 필드 결합 가능
    }
}
