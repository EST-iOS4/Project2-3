//
//  RecommendedVideoModel.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import Foundation

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
