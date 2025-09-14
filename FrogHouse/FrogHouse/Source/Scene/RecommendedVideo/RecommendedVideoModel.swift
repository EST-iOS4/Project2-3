//
//  RecommendedVideoModel.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import Foundation
struct RecommendedVideoModel: Equatable, Identifiable {
    let id: UUID
    let title: String
    let detail: String
    let tags: [String]
    let thumbnailURL: URL
    
    init(id: UUID, title: String, detail: String, tags: [String], thumbnailURL: URL) {
        self.id = id
        self.title = title
        self.detail = detail
        self.tags = tags
        self.thumbnailURL = thumbnailURL
    }
}

