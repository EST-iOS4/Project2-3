//
//  FirestoreVideoListDTO.swift
//  FrogHouse
//
//  Created by JAY on 9/16/25.
//

import Foundation
import FirebaseFirestore

struct FirestoreVideoListDTO: Codable {
    let id: String
    let title: String
    let description: String
    let categories: [String]
    let mp4URL: String
    let thumbnailURL: String
    let viewCount: Int
    @ServerTimestamp var createdAt: Timestamp?
    @ServerTimestamp var lastWatchedAt: Timestamp?
    let isLiked: Bool?
}
