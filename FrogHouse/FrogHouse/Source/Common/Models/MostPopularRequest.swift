//
//  MostPopularRequest.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

struct MostPopularRequest: Encodable {
    let part = "snippet"
    let chart = "mostPopular"
    let regionCode: RegionCode
    let maxResults: Int
    let videoCategoryId: VideoCategory
    let key: String
    
    init(regionCode: RegionCode,
         maxResults: Int,
         videoCategoryId: VideoCategory,
         key: String) {
        self.regionCode = regionCode
        self.maxResults = maxResults
        self.videoCategoryId = videoCategoryId
        self.key = key
    }
}
