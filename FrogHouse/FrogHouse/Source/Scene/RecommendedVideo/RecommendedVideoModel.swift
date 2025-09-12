//
//  RecommendedVideoModel.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import Foundation

struct RecommendedVideoModel: Equatable, Identifiable {
    
    let id = UUID()
    let title: String
    let detail: String
    let tags: [String]
    let thumbnailURL: URL
    
    // MARK: Jay - Init
    init(title: String, detail: String, tags: [String], thumbnailURL: URL) {
        self.title = title
        self.detail = detail
        self.tags = tags
        self.thumbnailURL = thumbnailURL
    }
}
