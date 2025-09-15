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

// MARK: Jay - 추천 비디오 Domain 모델 (UI/VM에서 사용)
struct RecommendedVideoModel: Equatable, Identifiable {
    // MARK: Jay - 고유 식별자 (UUID)
    let id: UUID
    // MARK: Jay - 제목
    let title: String
    // MARK: Jay - 상세 설명
    let detail: String
    // MARK: Jay - 태그 목록
    let tags: [String]
    // MARK: Jay - 썸네일 URL
    let thumbnailURL: URL

    // MARK: Jay - 초기화
    init(id: UUID, title: String, detail: String, tags: [String], thumbnailURL: URL) {
        self.id = id
        self.title = title
        self.detail = detail
        self.tags = tags
        self.thumbnailURL = thumbnailURL
    }
}

