//
//  RecommendedVideoModel.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import Foundation

public struct RecommendedVideoModel: Equatable, Identifiable {
    
    public let id = UUID()
    public let title: String
    public let detail: String
    public let tags: [String]
    public let thumbnailURL: URL
    
    // MARK: Jay - Init
    public init(title: String, detail: String, tags: [String], thumbnailURL: URL) {
        self.title = title
        self.detail = detail
        self.tags = tags
        self.thumbnailURL = thumbnailURL
    }
}
