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
    let id: UUID
    let title: String
    let detail: String
    let categories: [VideoCategory]
    let thumbnailURL: URL

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
