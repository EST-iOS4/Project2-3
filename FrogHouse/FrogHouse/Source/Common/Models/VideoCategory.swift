//
//  VideoCategory.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

enum VideoCategory: String, Encodable, CaseIterable {
    case all
    case music = "10"
    case sports = "17"
    case travel = "19"
    case gaming = "20"
    case movies = "30"
    
    var title: String {
        switch self {
        case .all:
            return "전체"
        case .travel:
            return "여행"
        case .music:
            return "음악"
        case .sports:
            return "스포츠"
        case .gaming:
            return "게임"
        case .movies:
            return "영화"
        }
    }
}
