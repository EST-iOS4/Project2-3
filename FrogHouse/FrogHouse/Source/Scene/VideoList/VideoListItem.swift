//
//  VideoListItem.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation

struct VideoListItem: Hashable {
    let id: UUID
    let thumbnailURL: URL?
    let title: String
    let descriptionText: String
    var isLiked: Bool
    let categories: [VideoCategory]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isLiked)
    }

    static func == (lhs: VideoListItem, rhs: VideoListItem) -> Bool {
        lhs.id == rhs.id && lhs.isLiked == rhs.isLiked
    }
}
