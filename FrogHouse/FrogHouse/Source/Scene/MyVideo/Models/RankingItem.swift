//
//  RankingItem.swift
//  FrogHouse
//
//  Created by 서정원 on 9/10/25.
//

import Foundation

struct RankingItem: Hashable {
    let id = UUID()
    let thumbnailURL: URL?
    let title: String
    let tag: [String]?
    let description: String
    let watchHistory: Int
}
